# Supplier Inventory View

# Tracks supplier stock availability, costs, and delivery times

view: supplier_inventory {
  sql_table_name: `gke-elastic-394012.spark_bi_alerts.supplier_inventory` ;;

  # Primary Key (composite)
  dimension: primary_key {
    primary_key: yes
    hidden: yes
    type: string
    sql: CONCAT(${supplier_name}, '-', ${sku}) ;;
  }

  # Dimensions
  dimension: supplier_name {
    type: string
    sql: ${TABLE}.supplier_name ;;
    description: "Name of the supplier"
  }

  dimension: sku {
    type: string
    sql: ${TABLE}.sku ;;
    description: "Stock Keeping Unit - Foreign Key to sales_data"
  }

  dimension: available_units {
    type: number
    sql: ${TABLE}.available_units ;;
    description: "Units available from this supplier"
  }

  dimension: unit_cost {
    type: number
    sql: ${TABLE}.unit_cost ;;
    value_format_name: usd
    description: "Cost per unit from this supplier"
  }

  dimension: delivery_hours {
    type: number
    sql: ${TABLE}.delivery_hours ;;
    description: "Estimated delivery time in hours"
  }

  # Derived Dimensions
  dimension: delivery_days {
    type: number
    sql: ${delivery_hours} / 24.0 ;;
    value_format: "0.0"
    description: "Estimated delivery time in days"
  }

  dimension: delivery_speed_tier {
    type: string
    sql: CASE
           WHEN ${delivery_hours} <= 24 THEN 'Same Day'
           WHEN ${delivery_hours} <= 48 THEN 'Next Day'
           WHEN ${delivery_hours} <= 72 THEN '2-3 Days'
           WHEN ${delivery_hours} <= 168 THEN '1 Week'
           ELSE 'Extended'
         END ;;
    description: "Delivery speed category"
  }

  dimension: cost_tier {
    type: tier
    tiers: [10, 25, 50, 100, 250]
    style: integer
    sql: ${unit_cost} ;;
    description: "Unit cost bucketed into tiers"
  }

  dimension: supplier_stock_status {
    type: string
    sql: CASE
           WHEN ${available_units} <= 0 THEN 'Out of Stock'
           WHEN ${available_units} < 50 THEN 'Low Stock'
           WHEN ${available_units} < 200 THEN 'Moderate'
           ELSE 'Well Stocked'
         END ;;
    description: "Supplier stock availability status"
  }

  # Time Dimensions
  dimension_group: last_checked {
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
    sql: ${TABLE}.last_checked ;;
    description: "Last time supplier inventory was checked"
  }

  dimension: hours_since_last_check {
    type: number
    sql: TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), ${last_checked_raw}, HOUR) ;;
    description: "Hours since the last inventory check"
  }

  # Measures
  measure: count {
    type: count
    drill_fields: [supplier_name, sku, available_units, unit_cost, delivery_hours]
  }

  measure: total_available_units {
    type: sum
    sql: ${available_units} ;;
    description: "Total available units across all suppliers"
  }

  measure: average_unit_cost {
    type: average
    sql: ${unit_cost} ;;
    value_format_name: usd
    description: "Average unit cost across suppliers"
  }

  measure: min_unit_cost {
    type: min
    sql: ${unit_cost} ;;
    value_format_name: usd
    description: "Minimum unit cost (cheapest supplier)"
  }

  measure: max_unit_cost {
    type: max
    sql: ${unit_cost} ;;
    value_format_name: usd
    description: "Maximum unit cost (most expensive supplier)"
  }

  measure: average_delivery_hours {
    type: average
    sql: ${delivery_hours} ;;
    value_format_name: decimal_0
    description: "Average delivery time in hours"
  }

  measure: fastest_delivery {
    type: min
    sql: ${delivery_hours} ;;
    description: "Fastest delivery time in hours"
  }

  measure: unique_suppliers {
    type: count_distinct
    sql: ${supplier_name} ;;
    description: "Count of unique suppliers"
  }

  measure: unique_skus {
    type: count_distinct
    sql: ${sku} ;;
    description: "Count of unique SKUs from suppliers"
  }

  measure: total_inventory_value {
    type: sum
    sql: ${available_units} * ${unit_cost} ;;
    value_format_name: usd
    description: "Total value of supplier inventory"
  }
}
