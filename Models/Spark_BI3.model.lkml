# Unified Retail Analytics Model

# Connects all 5 tables: sales_data, inventory_stock, supplier_inventory,
# competitor_market_data, and social_trends based on the architecture diagram

connection: "spark_bi"

# Include all view files
include: "/Views/*.view.lkml"

# Data groups for caching
datagroup: daily_refresh {
  max_cache_age: "24 hours"
  sql_trigger: SELECT CURRENT_DATE() ;;
}

datagroup: hourly_refresh {
  max_cache_age: "1 hour"
  sql_trigger: SELECT EXTRACT(HOUR FROM CURRENT_TIMESTAMP()) ;;
}

persist_with: daily_refresh

# =============================================================================
# UNIFIED RETAIL ANALYTICS EXPLORE
# Central explore that joins all tables around sales_data
# =============================================================================

explore: sales_data {
  label: "Unified Retail Analytics"
  description: "Comprehensive view combining sales, inventory, suppliers, competitors, and social trends"

  # Join to Inventory Stock (via SKU)
  join: inventory_stock {
    type: left_outer
    relationship: one_to_many
    sql_on: ${sales_data.sku} = ${inventory_stock.sku} ;;
  }

  # Join to Supplier Inventory (via SKU)
  join: supplier_inventory {
    type: left_outer
    relationship: one_to_many
    sql_on: ${sales_data.sku} = ${supplier_inventory.sku} ;;
  }

  # Join to Competitor Market Data (via SKU)
  join: competitor_market_data {
    type: left_outer
    relationship: one_to_many
    sql_on: ${sales_data.sku} = ${competitor_market_data.sku} ;;
  }

  # Join to Social Trends (via related_sku AND category + time window)
  join: social_trends {
    type: left_outer
    relationship: one_to_many
    sql_on: ${sales_data.sku} = ${social_trends.related_sku}
            OR (${sales_data.category} = ${social_trends.related_category}
                AND ${sales_data.timestamp_date} = ${social_trends.event_date}) ;;
  }
}

# =============================================================================
# INVENTORY FOCUSED EXPLORE
# For inventory management and stock analysis
# =============================================================================

explore: inventory_stock {
  label: "Inventory Management"
  description: "Focus on inventory levels with supplier availability"

  join: sales_data {
    type: left_outer
    relationship: many_to_one
    sql_on: ${inventory_stock.sku} = ${sales_data.sku} ;;
  }

  join: supplier_inventory {
    type: left_outer
    relationship: one_to_many
    sql_on: ${inventory_stock.sku} = ${supplier_inventory.sku} ;;
  }
}

# =============================================================================
# COMPETITIVE ANALYSIS EXPLORE
# For competitor pricing and market intelligence
# =============================================================================

explore: competitor_market_data {
  label: "Competitive Intelligence"
  description: "Analyze competitor pricing and stock availability"

  join: sales_data {
    type: left_outer
    relationship: many_to_one
    sql_on: ${competitor_market_data.sku} = ${sales_data.sku} ;;
  }

  join: inventory_stock {
    type: left_outer
    relationship: one_to_many
    sql_on: ${competitor_market_data.sku} = ${inventory_stock.sku} ;;
  }
}

# =============================================================================
# SOCIAL TRENDS EXPLORE
# For trend analysis and demand forecasting
# =============================================================================

explore: social_trends {
  label: "Social Trend Analysis"
  description: "Analyze social media trends and their impact on sales"

  join: sales_data {
    type: left_outer
    relationship: many_to_many
    sql_on: ${social_trends.related_sku} = ${sales_data.sku}
            OR (${social_trends.related_category} = ${sales_data.category}
                AND ${social_trends.event_date} = ${sales_data.timestamp_date}) ;;
  }
}

# =============================================================================
# SUPPLIER ANALYSIS EXPLORE
# For supplier performance and cost analysis
# =============================================================================

explore: supplier_inventory {
  label: "Supplier Analysis"
  description: "Analyze supplier inventory, costs, and delivery performance"

  join: sales_data {
    type: left_outer
    relationship: many_to_one
    sql_on: ${supplier_inventory.sku} = ${sales_data.sku} ;;
  }

  join: inventory_stock {
    type: left_outer
    relationship: one_to_many
    sql_on: ${supplier_inventory.sku} = ${inventory_stock.sku} ;;
  }

  join: competitor_market_data {
    type: left_outer
    relationship: one_to_many
    sql_on: ${supplier_inventory.sku} = ${competitor_market_data.sku} ;;
  }
}
