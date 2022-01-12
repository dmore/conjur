# frozen_string_literal: true

module Authentication
  module AuthnJwt
    PROVIDER_URI_RESOURCE_NAME = "provider-uri"
    JWKS_URI_RESOURCE_NAME = "jwks-uri"
    PUBLIC_KEYS_RESOURCE_NAME = "public-keys"
    CA_CERT_RESOURCE_NAME = "ca-cert"
    PROVIDER_URI_INTERFACE_NAME = PROVIDER_URI_RESOURCE_NAME.freeze
    JWKS_URI_INTERFACE_NAME = JWKS_URI_RESOURCE_NAME.freeze
    PUBLIC_KEYS_INTERFACE_NAME = PUBLIC_KEYS_RESOURCE_NAME.freeze
    ISSUER_RESOURCE_NAME = "issuer"
    TOKEN_APP_PROPERTY_VARIABLE = "token-app-property"
    IDENTITY_NOT_RETRIEVED_YET = "Identity not retrieved yet"
    URL_IDENTITY_PROVIDER_INTERFACE_NAME = "url-identity-provider"
    TOKEN_IDENTITY_PROVIDER_INTERFACE_NAME = "token-identity-provider"
    IDENTITY_PATH_RESOURCE_NAME = "identity-path"
    IDENTITY_PATH_DEFAULT_VALUE = ""
    PATH_DELIMITER = "/"
    IDENTITY_TYPE_HOST = "host"
    ENFORCED_CLAIMS_RESOURCE_NAME = "enforced-claims"
    CLAIM_ALIASES_RESOURCE_NAME = "claim-aliases"
    AUDIENCE_RESOURCE_NAME = "audience"
    PRIVILEGE_AUTHENTICATE="authenticate"
    ISS_CLAIM_NAME = "iss"
    EXP_CLAIM_NAME = "exp"
    NBF_CLAIM_NAME = "nbf"
    IAT_CLAIM_NAME = "iat"
    JTI_CLAIM_NAME = "jti"
    AUD_CLAIM_NAME = "aud"
    SUPPORTED_ALGORITHMS = %w[RS256 RS384 RS512].freeze
    CACHE_REFRESHES_PER_INTERVAL = 10
    CACHE_RATE_LIMIT_INTERVAL = 300
    CACHE_MAX_CONCURRENT_REQUESTS = 3
    MANDATORY_CLAIMS = [EXP_CLAIM_NAME].freeze
    OPTIONAL_CLAIMS = [ISS_CLAIM_NAME, NBF_CLAIM_NAME, IAT_CLAIM_NAME].freeze
    CLAIMS_DENY_LIST = [ISS_CLAIM_NAME, EXP_CLAIM_NAME, NBF_CLAIM_NAME, IAT_CLAIM_NAME, JTI_CLAIM_NAME, AUD_CLAIM_NAME].freeze
    CLAIMS_CHARACTER_DELIMITER = ","
    TUPLE_CHARACTER_DELIMITER = ":"

    PURE_CLAIM_NAME_REGEX = /[a-zA-Z|$|_][a-zA-Z|$|_|0-9|.]*/.freeze
    PURE_NESTED_CLAIM_NAME_REGEX = /^#{PURE_CLAIM_NAME_REGEX.source}(#{PATH_DELIMITER}#{PURE_CLAIM_NAME_REGEX.source})*$/.freeze
  end
end
