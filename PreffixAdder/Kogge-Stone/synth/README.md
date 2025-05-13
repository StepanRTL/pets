## Разбор скрипта для запуска синтеза

### 1. Параметризация

Следующий код читает все файлы с HDL-кодом из директории с именем ${DESIGN_NAME}.

```tcl
set DESIGN_NAME "../rtl"
set verilog_files [glob -nocomplain -dir ${DESIGN_NAME} *.sv]
foreach file ${verilog_files} {
	read_hdl -sv $file
}
```
### 2. Подключение технологической библиотеки

```tcl
set_db library /tools/PDK_DDK/CORELIB8DHS_3.1.a/liberty/wc_1.20V_105C/CORELIB8DHS.lib
```

### 3. Построение иерархии дизайна

```tcl
elaborate
```

### 4. Создание тактового сигнала с частотой 100 Мгц

Важно заметить, что период тактового сигнала задается в пикосекундах.
```tcl
define_clock -name clk_i -period 10000 clk_i
```
### 5. Запуск синтеза


```tcl
syn_generic
syn_map
syn_opt
```

Команда ``syn_generic`` преобразует абстрактные блоки в набор логических элементов, не привязанных к технологической библиотеке.

Команда ``syn_map`` заменяет "идеальные" логические элементы на "реальные" с разными размерами и задержками. Синтезатор подбирает нужные элементы из liberty-файла таким образом, чтобы выполнялись проектные ограничения.

Команда ``syn_opt`` оптимизирует созданный netlist на этапе маппинга.

### 6. Запись нетлист в Verilog-файл

```tcl
write_hdl > netlist.sv
```

### 7. Создание различных отчетов

```tcl
report timing > reports/timing.rpt
report area   > reports/area.rpt
report power  > reports/power.rpt
report qor    > reports/qor.rpt
check_timing -verbose
```

### 8. Выход из консоли Genus

```tcl
exit
```
