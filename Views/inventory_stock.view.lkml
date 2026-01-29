# Inventory Stock View

# Tracks current inventory levels across warehouses

view: inventory_stock {
  sql_table_name: `gke-elastic-394012.spark_bi_alerts.inventory_stock` ;;

  # Primary Key (composite)
  dimension: primary_key {
    primary_key: yes
    hidden: yes
    type: string
    sql: CONCAT(${sku}, '-', ${warehouse_id}) ;;
  }

  # Dimensions
  dimension: sku {
    type: string
    sql: ${TABLE}.sku ;;
    description: "Stock Keeping Unit - Foreign Key to sales_data"
  }

  dimension: warehouse_id {
    type: string
    sql: ${TABLE}.warehouse_id ;;
    description: "Unique identifier for the warehouse"
  }

  dimension: current_stock {
    type: number
    sql: ${TABLE}.current_stock ;;
    description: "Current available stock quantity"
  }

  dimension: reserved_stock {
    type: number
    sql: ${TABLE}.reserved_stock ;;
    description: "Stock reserved for pending orders"
  }

  # Derived Dimensions
  dimension: available_stock {
    type: number
    sql: ${current_stock} - ${reserved_stock} ;;
    description: "Actual available stock (current - reserved)"
  }

  dimension: stock_status {
    type: string
    sql: CASE
           WHEN ${available_stock} <= 0 THEN 'Out of Stock'
           WHEN ${available_stock} < 10 THEN 'Critical Low'
           WHEN ${available_stock} < 50 THEN 'Low Stock'
           WHEN ${available_stock} < 100 THEN 'Moderate'
           ELSE 'Healthy'
         END ;;
    description: "Stock health status based on available units"
  }

  dimension: reservation_percentage {
    type: number
    sql: SAFE_DIVIDE(${reserved_stock}, ${current_stock}) * 100 ;;
    value_format: "0.00\"%\""
    description: "Percentage of stock that is reserved"
  }

  # Time Dimensions
  dimension_group: last_updated {
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
    sql: ${TABLE}.last_updated ;;
    description: "Last time the inventory was updated"
  }

  # Measures
  measure: count {
    type: count
    drill_fields: [sku, warehouse_id, current_stock, reserved_stock]
  }

  measure: total_current_stock {
    type: sum
    sql: ${current_stock} ;;
    description: "Total current stock across all warehouses"
  }

  measure: total_reserved_stock {
    type: sum
    sql: ${reserved_stock} ;;
    description: "Total reserved stock across all warehouses"
  }

  measure: total_available_stock {
    type: sum
    sql: ${available_stock} ;;
    description: "Total available stock (current - reserved)"
  }

  measure: average_stock_per_warehouse {
    type: average
    sql: ${current_stock} ;;
    value_format_name: decimal_0
    description: "Average stock per warehouse"
  }

  measure: unique_warehouses {
    type: count_distinct
    sql: ${warehouse_id} ;;
    description: "Count of unique warehouses"
  }

  measure: unique_skus {
    type: count_distinct
    sql: ${sku} ;;
    description: "Count of unique SKUs in inventory"
  }

  measure: out_of_stock_count {
    type: count
    filters: [stock_status: "Out of Stock"]
    description: "Count of out-of-stock items"
  }

  measure: low_stock_count {
    type: count
    filters: [stock_status: "Critical Low, Low Stock"]
    description: "Count of low stock items"
  }
}
