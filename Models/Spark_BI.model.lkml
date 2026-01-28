connection: "spark_bi"

include: "/Views/*.view.lkml"

explore: spark_bi_unified {
  label: "Spark BI – Unified Analytics"
  from: sales_data
  view_name: sales_data

  join: inventory_stock {
    type: left_outer
    relationship: many_to_one
    sql_on: ${sales_data.sku} = ${inventory_stock.sku} ;;
  }

  join: competitor_market_data {
    type: left_outer
    relationship: many_to_many
    sql_on: ${sales_data.sku} = ${competitor_market_data.sku} ;;
  }

  join: supplier_inventory {
    type: left_outer
    relationship: many_to_one
    sql_on: ${sales_data.sku} = ${supplier_inventory.sku} ;;
  }

  join: social_trends {
    type: left_outer
    relationship: many_to_many
    sql_on: ${sales_data.sku} = ${social_trends.related_sku} ;;
  }
}

# -----------------------------
# Core Explore: Sales
# -----------------------------
explore: sales_data {
  label: "Sales Analytics"

  join: inventory_stock {
    type: left_outer
    relationship: many_to_one
    sql_on: ${sales_data.sku} = ${inventory_stock.sku} ;;
  }

  join: competitor_market_data {
    type: left_outer
    relationship: many_to_many
    sql_on: ${sales_data.sku} = ${competitor_market_data.sku} ;;
  }

  join: supplier_inventory {
    type: left_outer
    relationship: many_to_one
    sql_on: ${sales_data.sku} = ${supplier_inventory.sku} ;;
  }

  join: social_trends {
    type: left_outer
    relationship: many_to_many
    sql_on: ${sales_data.sku} = ${social_trends.related_sku} ;;
  }
}

# -----------------------------
# Inventory-focused Explore
# -----------------------------
explore: inventory_stock {
  label: "Inventory Status"

  join: supplier_inventory {
    type: left_outer
    relationship: many_to_one
    sql_on: ${inventory_stock.sku} = ${supplier_inventory.sku} ;;
  }

  join: competitor_market_data {
    type: left_outer
    relationship: many_to_many
    sql_on: ${inventory_stock.sku} = ${competitor_market_data.sku} ;;
  }
}

# -----------------------------
# Competitor Pricing Explore
# -----------------------------
explore: competitor_market_data {
  label: "Competitor Pricing"

  join: sales_data {
    type: left_outer
    relationship: many_to_one
    sql_on: ${competitor_market_data.sku} = ${sales_data.sku} ;;
  }
}

# -----------------------------
# Social Trends Explore
# -----------------------------
explore: social_trends {
  label: "Social Trends & Demand Signals"
}
