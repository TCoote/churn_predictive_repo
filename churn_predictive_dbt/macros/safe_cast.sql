{#
  Macro: safe_cast
  
  Purpose: Safely cast a column to a target type, returning NULL if cast fails.
  This prevents bad data from breaking transformations.
  
  Args:
    column_name (string): Name of the column to cast
    target_type (string): Target data type (e.g., 'int', 'decimal(10,2)', 'boolean')
  
  Example:
    {{ safe_cast('tenure_months', 'int') }}
    Output: TRY_CAST(tenure_months AS INT)
#}

{% macro safe_cast(column_name, target_type) %}
  TRY_CAST({{ column_name }} AS {{ target_type }})
{% endmacro %}
