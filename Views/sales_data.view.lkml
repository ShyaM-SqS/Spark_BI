# Sales Data View

# Central fact table containing all sales transactions

view: sales_data {
  sql_table_name: `gke-elastic-394012.spark_bi_alerts.sales_data` ;;

  # Primary Key (composite)
  dimension: primary_key {
    primary_key: yes
    hidden: yes
    type: string
    sql: CONCAT(${sku}, '-', CAST(${timestamp_raw} AS STRING)) ;;
  }

  # Dimensions
  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
    description: "Product category - used for joining with social_trends"
  }

  dimension: sku {
    type: string
    sql: ${TABLE}.sku ;;
    description: "Stock Keeping Unit - Foreign Key to inventory, supplier, and competitor tables"
  }

  dimension: product_name {
    type: string
    sql: ${TABLE}.product_name ;;
    description: "Name of the product"
  }

  dimension: sales_volume {
    type: number
    sql: ${TABLE}.sales_volume ;;
    description: "Number of units sold"
  }

  dimension: revenue {
    type: number
    sql: ${TABLE}.revenue ;;
    value_format_name: usd
    description: "Revenue generated from the sale"
  }

  # Time Dimensions
  dimension_group: timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year,
      day_of_week,
      hour_of_day
    ]
    sql: ${TABLE}.timestamp ;;
    description: "Timestamp of the sales transaction"
  }

  # Derived Dimensions
  dimension: revenue_tier {
    type: tier
    tiers: [100, 500, 1000, 5000, 10000]
    style: integer
    sql: ${revenue} ;;
    description: "Revenue bucketed into tiers"
  }

  dimension: sales_volume_tier {
    type: tier
    tiers: [10, 50, 100, 500, 1000]
    style: integer
    sql: ${sales_volume} ;;
    description: "Sales volume bucketed into tiers"
  }

  # Measures
  measure: count {
    type: count
    drill_fields: [sku, product_name, category, revenue, sales_volume]
  }

  measure: total_revenue {
    type: sum
    sql: ${revenue} ;;
    value_format_name: usd
    description: "Total revenue across all sales"
  }

  measure: total_sales_volume {
    type: sum
    sql: ${sales_volume} ;;
    description: "Total units sold"
  }

  measure: average_revenue {
    type: average
    sql: ${revenue} ;;
    value_format_name: usd
    description: "Average revenue per transaction"
  }

  measure: average_sales_volume {
    type: average
    sql: ${sales_volume} ;;
    value_format_name: decimal_0
    description: "Average units sold per transaction"
  }

  measure: min_revenue {
    type: min
    sql: ${revenue} ;;
    value_format_name: usd
  }

  measure: max_revenue {
    type: max
    sql: ${revenue} ;;
    value_format_name: usd
  }

  measure: unique_products {
    type: count_distinct
    sql: ${sku} ;;
    description: "Count of unique products sold"
  }

  measure: unique_categories {
    type: count_distinct
    sql: ${category} ;;
    description: "Count of unique categories"
  }

  measure: revenue_per_unit {
    type: number
    sql: ${total_revenue} / NULLIF(${total_sales_volume}, 0) ;;
    value_format_name: usd
    description: "Average revenue per unit sold"
  }
}
