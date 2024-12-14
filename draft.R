library(pacman)
p_load(tidyverse,DBI,RSQLite,fs)

if(file_exists("data/TYSQL.sqlite")) {
  file_delete("data/TYSQL.sqlite")
  cat("EXECUTE DELETE.")
}

# 连接数据库
conn <- dbConnect(RSQLite::SQLite(), "data/TYSQL.sqlite")  

# 创建数据库
read_lines("data/my_create.txt") -> sql_code

str_subset(sql_code,pattern = "^--",negate = T) %>% 
  map_chr(\(x) str_replace(x,"\\);$",");[FLAG]")) %>% 
  str_c(collapse = "\n") %>% 
  str_squish() %>% 
  str_remove("\\[FLAG\\]$") %>%  
  str_split("\\[FLAG\\]") %>% 
  unlist() -> sql_statements

# 执行 SQL 语句
for (sql in sql_statements) {
  if (nchar(sql) > 0) {
    tryCatch({
      dbExecute(conn, sql)  # 执行每条 SQL 语句
    }, error = function(e) {
      message("Error executing SQL: ", e$message, " in SQL: ", sql)
    })
  }
}

# 观察数据库中的所有表格
dbListTables(conn) -> all_tables
all_tables
lapply(all_tables, function(x) tbl(conn,x))


# 插入数据
read_lines("data/my_populate.txt") -> sql_code

str_subset(sql_code,pattern = "^--",negate = T) %>% 
  map_chr(\(x) str_replace(x,"\\);$",");[FLAG]")) %>% 
  str_c(collapse = "\n") %>% 
  str_squish() %>% 
  str_remove("\\[FLAG\\]$") %>%  
  str_split("\\[FLAG\\]") %>% 
  unlist() -> sql_statements

# 执行 SQL 语句
for (sql in sql_statements) {
  if (nchar(sql) > 0) {
    tryCatch({
      dbExecute(conn, sql)  # 执行每条 SQL 语句
    }, error = function(e) {
      message("Error executing SQL: ", e$message, " in SQL: ", sql)
    })
  }
}

# 观察数据库中的所有表格
dbListTables(conn) -> all_tables
lapply(all_tables, function(x) tbl(conn,x))

# 关闭数据库连接
dbDisconnect(conn)