# Competitor Market Data View

# Tracks competitor pricing and stock availability

view: competitor_market_data {
  sql_table_name: `gke-elastic-394012.spark_bi_alerts.competitor_market_data` ;;

  # Primary Key (composite)
  dimension: primary_key {
    primary_key: yes
    hidden: yes
    type: string
    sql: CONCAT(${competitor_name}, '-', ${sku}, '-', CAST(${checked_timestamp_raw} AS STRING)) ;;
  }

  # Dimensions
  dimension: competitor_name {
    type: string
    sql: ${TABLE}.competitor_name ;;
    description: "Name of the competitor"
  }

  dimension: sku {
    type: string
    sql: ${TABLE}.sku ;;
    description: "Stock Keeping Unit - Foreign Key to sales_data"
  }

  dimension: product_name {
    type: string
    sql: ${TABLE}.product_name ;;
    description: "Product name as listed by competitor"
  }

  dimension: price {
    type: number
    sql: ${TABLE}.price ;;
    value_format_name: usd
    description: "Competitor's current price"
  }

  dimension: price_change_pct {
    type: number
    sql: ${TABLE}.price_change_pct ;;
    value_format: "0.00\"%\""
    description: "Percentage change in price"
  }

  dimension: stock_status {
    type: string
    sql: ${TABLE}.stock_status ;;
    description: "Competitor's stock availability status"
  }

  # Derived Dimensions
  dimension: price_movement {
    type: string
    sql: CASE
           WHEN ${price_change_pct} > 5 THEN 'Significant Increase'
           WHEN ${price_change_pct} > 0 THEN 'Slight Increase'
           WHEN ${price_change_pct} = 0 THEN 'No Change'
           WHEN ${price_change_pct} > -5 THEN 'Slight Decrease'
           ELSE 'Significant Decrease'
         END ;;
    description: "Categorized price movement"
  }

  dimension: price_tier {
    type: tier
    tiers: [25, 50, 100, 250, 500]
    style: integer
    sql: ${price} ;;
    description: "Price bucketed into tiers"
  }

  dimension: is_in_stock {
    type: yesno
    sql: LOWER(${stock_status}) IN ('in stock', 'available', 'in_stock') ;;
    description: "Whether the competitor has the item in stock"
  }

  # Time Dimensions
  dimension_group: checked_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.checked_timestamp ;;
    description: "When the competitor data was captured"
  }

  dimension: hours_since_check {
    type: number
    sql: TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), ${checked_timestamp_raw}, HOUR) ;;
    description: "Hours since the last competitive check"
  }

  # Measures
  measure: count {
    type: count
    drill_fields: [competitor_name, sku, product_name, price, stock_status]
  }

  measure: average_competitor_price {
    type: average
    sql: ${price} ;;
    value_format_name: usd
    description: "Average price across competitors"
  }

  measure: min_competitor_price {
    type: min
    sql: ${price} ;;
    value_format_name: usd
    description: "Lowest competitor price"
  }

  measure: max_competitor_price {
    type: max
    sql: ${price} ;;
    value_format_name: usd
    description: "Highest competitor price"
  }

  measure: price_range {
    type: number
    sql: ${max_competitor_price} - ${min_competitor_price} ;;
    value_format_name: usd
    description: "Difference between highest and lowest competitor prices"
  }

  measure: average_price_change {
    type: average
    sql: ${price_change_pct} ;;
    value_format: "0.00\"%\""
    description: "Average price change percentage"
  }

  measure: unique_competitors {
    type: count_distinct
    sql: ${competitor_name} ;;
    description: "Count of unique competitors tracked"
  }

  measure: unique_products {
    type: count_distinct
    sql: ${sku} ;;
    description: "Count of unique products tracked"
  }

  measure: in_stock_count {
    type: count
    filters: [is_in_stock: "yes"]
    description: "Count of items in stock at competitors"
  }

  measure: out_of_stock_count {
    type: count
    filters: [is_in_stock: "no"]
    description: "Count of items out of stock at competitors"
  }

  measure: in_stock_rate {
    type: number
    sql: ${in_stock_count} / NULLIF(${count}, 0) * 100 ;;
    value_format: "0.00\"%\""
    description: "Percentage of items in stock at competitors"
  }
}
