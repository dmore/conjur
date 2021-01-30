# frozen_string_literal: true

Sequel.migration do
  tables = %i[roles role_memberships resources permissions annotations]
  
  up do
    # `policy_log_record` is a custom type to record the column
    # definitions for the policy log records generated by each of
    # the `policy_log_#{table}_record` functions
    execute <<-SQL
    CREATE TYPE policy_log_record as (
      policy_id text,
      version int,
      operation policy_log_op,
      kind policy_log_kind,
      subject hstore
      );
    SQL

    # This function is used both by the policy_log trigger for each
    # table, as well as for the bulk insert policy log in the policy
    # load orchestrator.
    execute <<-SQL
      CREATE OR REPLACE FUNCTION policy_log_record(
        table_name text,
        pkey_cols text[],
        subject hstore,
        policy_id text,
        policy_version int,
        operation text
      ) RETURNS policy_log_record AS $$
      BEGIN
        return (
          policy_id,
          policy_version,
          operation::policy_log_op,
          table_name::policy_log_kind,
          slice(subject, pkey_cols)
          );
      END;
      $$ LANGUAGE plpgsql;
    SQL

    tables.each do |table|
      # find the primary key of the table
      primary_key_columns = schema(table).select{|x,s|s[:primary_key]}.map(&:first).map(&:to_s).pg_array
      execute <<-SQL
        CREATE OR REPLACE FUNCTION policy_log_#{table}() RETURNS TRIGGER AS $$
          DECLARE
            subject #{table};
            current policy_versions;
            skip boolean;
          BEGIN
            IF (TG_OP = 'DELETE') THEN
              subject := OLD;
            ELSE
              subject := NEW;
            END IF;

            BEGIN
                skip := current_setting('conjur.skip_insert_policy_log_trigger');
            EXCEPTION WHEN OTHERS THEN
                skip := false;
            END;

            IF skip THEN
              RETURN subject;
            END IF;

            current = current_policy_version();
            IF current.resource_id = subject.policy_id THEN
              INSERT INTO policy_log(
                policy_id, version,
                operation, kind,
                subject)
              SELECT
                (policy_log_record(
                    '#{table}',
                    #{literal primary_key_columns},
                    hstore(subject),
                    current.resource_id,
                    current.version,
                    TG_OP
                  )).*;
            ELSE
              RAISE WARNING 'modifying data outside of policy load: %', subject.policy_id;
            END IF;
            RETURN subject;
          END;
        $$ LANGUAGE plpgsql
        SET search_path FROM CURRENT;
      SQL
    end
  end

  down do
    tables.each do |table|
      # find the primary key of the table
      primary_key_columns = schema(table).select{|x,s|s[:primary_key]}.map(&:first).map(&:to_s).pg_array
      execute <<-SQL
        CREATE OR REPLACE FUNCTION policy_log_#{table}() RETURNS TRIGGER AS $$
          DECLARE
            subject #{table};
            current policy_versions;
          BEGIN
            IF (TG_OP = 'DELETE') THEN
              subject := OLD;
            ELSE
              subject := NEW;
            END IF;
            current = current_policy_version();
            IF current.resource_id = subject.policy_id THEN
              INSERT INTO policy_log(
                policy_id, version,
                operation, kind,
                subject)
              SELECT
                current.resource_id, current.version,
                TG_OP::policy_log_op, '#{table}'::policy_log_kind,
                slice(hstore(subject), #{literal primary_key_columns})
              ;
            ELSE
              RAISE WARNING 'modifying data outside of policy load: %', subject.policy_id;
            END IF;
            RETURN subject;
          END;
        $$ LANGUAGE plpgsql
        SET search_path FROM CURRENT;
      SQL

      
    end

    execute <<-SQL
      DROP FUNCTION IF EXISTS policy_log_record(
        table_name text,
        pkey_cols text[],
        subject hstore,
        policy_id text,
        policy_version int,
        operation text
      );
    SQL

    execute 'DROP TYPE policy_log_record;'
  end
end
