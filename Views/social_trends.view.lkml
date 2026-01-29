# Social Trends View

# Captures trending topics and their relationship to product categories and SKUs

view: social_trends {
  sql_table_name: `gke-elastic-394012.spark_bi_alerts.social_trends` ;;

  # Primary Key
  dimension: trend_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.trend_id ;;
    description: "Unique identifier for each social trend"
  }

  # Dimensions
  dimension: trend_name {
    type: string
    sql: ${TABLE}.trend_name ;;
    description: "Name of the trending topic"
  }

  dimension: platform {
    type: string
    sql: ${TABLE}.platform ;;
    description: "Social media platform where the trend originated"
  }

  dimension: mentions_count {
    type: number
    sql: ${TABLE}.mentions_count ;;
    description: "Number of mentions across the platform"
  }

  dimension: country_count {
    type: number
    sql: ${TABLE}.country_count ;;
    description: "Number of countries where the trend is active"
  }

  dimension: related_category {
    type: string
    sql: ${TABLE}.related_category ;;
    description: "Product category related to this trend - used for joining with sales_data"
  }

  dimension: related_sku {
    type: string
    sql: ${TABLE}.related_sku ;;
    description: "Product SKU related to this trend - Foreign Key to sales_data"
  }

  # Time Dimensions
  dimension_group: event {
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
    sql: ${TABLE}.event_timestamp ;;
    description: "Timestamp when the trend was captured"
  }

  # Measures
  measure: count {
    type: count
    drill_fields: [trend_id, trend_name, platform, mentions_count]
  }

  measure: total_mentions {
    type: sum
    sql: ${mentions_count} ;;
    description: "Total mentions across all trends"
  }

  measure: average_mentions {
    type: average
    sql: ${mentions_count} ;;
    value_format_name: decimal_0
    description: "Average mentions per trend"
  }

  measure: total_country_reach {
    type: sum
    sql: ${country_count} ;;
    description: "Total country reach across all trends"
  }

  measure: max_mentions {
    type: max
    sql: ${mentions_count} ;;
    description: "Maximum mentions for a single trend"
  }
}
