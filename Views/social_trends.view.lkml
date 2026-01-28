view: social_trends {
  sql_table_name: `gke-elastic-394012.spark_bi_alerts.social_trends` ;;

  dimension: country_count {
    type: number
    sql: ${TABLE}.country_count ;;
  }
  dimension_group: event_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.event_timestamp ;;
  }
  dimension: mentions_count {
    type: number
    sql: ${TABLE}.mentions_count ;;
  }
  dimension: platform {
    type: string
    sql: ${TABLE}.platform ;;
  }
  dimension: related_category {
    type: string
    sql: ${TABLE}.related_category ;;
  }
  dimension: related_sku {
    type: string
    sql: ${TABLE}.related_sku ;;
  }
  dimension: trend_id {
    type: string
    sql: ${TABLE}.trend_id ;;
  }
  dimension: trend_name {
    type: string
    sql: ${TABLE}.trend_name ;;
  }
  measure: count {
    type: count
    drill_fields: [trend_name]
  }
}
