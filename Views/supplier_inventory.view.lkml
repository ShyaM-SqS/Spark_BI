view: supplier_inventory {
  sql_table_name: `gke-elastic-394012.spark_bi_alerts.supplier_inventory` ;;

  dimension: available_units {
    type: number
    sql: ${TABLE}.available_units ;;
  }
  dimension: delivery_hours {
    type: number
    sql: ${TABLE}.delivery_hours ;;
  }
  dimension_group: last_checked {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.last_checked ;;
  }
  dimension: sku {
    type: string
    sql: ${TABLE}.sku ;;
  }
  dimension: supplier_name {
    type: string
    sql: ${TABLE}.supplier_name ;;
  }
  dimension: unit_cost {
    type: number
    sql: ${TABLE}.unit_cost ;;
  }
  measure: count {
    type: count
    drill_fields: [supplier_name]
  }
}
