view: competitor_market_data {
  sql_table_name: `gke-elastic-394012.spark_bi_alerts.competitor_market_data` ;;

  dimension_group: checked_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.checked_timestamp ;;
  }
  dimension: competitor_name {
    type: string
    sql: ${TABLE}.competitor_name ;;
  }
  dimension: price {
    type: number
    sql: ${TABLE}.price ;;
  }
  dimension: price_change_pct {
    type: number
    sql: ${TABLE}.price_change_pct ;;
  }
  dimension: product_name {
    type: string
    sql: ${TABLE}.product_name ;;
  }
  dimension: sku {
    type: string
    sql: ${TABLE}.sku ;;
  }
  dimension: stock_status {
    type: string
    sql: ${TABLE}.stock_status ;;
  }
  measure: count {
    type: count
    drill_fields: [competitor_name, product_name]
  }
}
