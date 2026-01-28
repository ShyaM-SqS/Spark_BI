view: sales_data {
  sql_table_name: `gke-elastic-394012.spark_bi_alerts.sales_data` ;;

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }
  dimension: product_name {
    type: string
    sql: ${TABLE}.product_name ;;
  }
  dimension: revenue {
    type: number
    sql: ${TABLE}.revenue ;;
  }
  dimension: sales_volume {
    type: number
    sql: ${TABLE}.sales_volume ;;
  }
  dimension: sku {
    type: string
    sql: ${TABLE}.sku ;;
  }
  dimension_group: timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.timestamp ;;
  }
  measure: count {
    type: count
    drill_fields: [product_name]
  }
}
