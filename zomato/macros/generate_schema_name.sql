-- Overrides dbt's default schema naming (which would produce
-- "<target_schema>_<custom_schema>", e.g. staging_marts). Instead, a
-- model's +schema config (staging/marts/snapshot) is used as-is, so
-- models land directly in ZOMATO.STAGING / ZOMATO.MARTS / ZOMATO.SNAPSHOT.
{% macro generate_schema_name(
        custom_schema_name,
        node
    ) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
