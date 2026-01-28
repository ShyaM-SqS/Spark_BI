view: inventory_stock {
  sql_table_name: `gke-elastic-394012.spark_bi_alerts.inventory_stock` ;;

  dimension: current_stock {
    type: number
    sql: ${TABLE}.current_stock ;;
  }
  dimension_group: last_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.last_updated ;;
  }
  dimension: reserved_stock {
    type: number
    sql: ${TABLE}.reserved_stock ;;
  }
  dimension: sku {
    type: string
    sql: ${TABLE}.sku ;;
  }
  dimension: warehouse_id {
    type: string
    sql: ${TABLE}.warehouse_id ;;
  }
  measure: count {
    type: count
  }
}
