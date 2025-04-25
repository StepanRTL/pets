##  Преобразователь valid/credit интерфейса в valid/ready интерфейс

Согласно ТЗ, устройство должно уметь накапливать входные данные, так как данные m_data_o считаются переданными, если произойдет хэндшейк m_valid_o && m_ready_i, а не факт, что slave устройство способно выставлять сигнал m_ready_i каждый такт. Поэтому был установлен буфер FIFO.

### Принцип работы
#### FIFO

**Шапка модуля**

```Verilog
module fifo #(parameter WIDTH = 8, DEPTH = 10)(
  input                clk_i,
  input                rstn_i,
  input                push_i,
  input                pop_i,
  input  [WIDTH - 1:0] data_i,
  output [WIDTH - 1:0] data_o,
  output               empty_o,
  output               full_o
);
```
**Входные сигналы:**
 * clk_i — тактовый сигнал
 * rstn_i — синхронный сброс с активным нулем
 * push_i — сигнал записи
 * pop_i — сигнал чтения
 * data_i — записываемые данные

**Выходные сигналы:**
 * data_o — читаемые данные
 * empty_o — FIFO пустой
 * full_o — FIFO полный

Буфер был оптимизирован за счет изменения логики формирования сигналов full_o и empty_o. В классической реализации FIFO заводится счетчик заполненности буфера — fill_counter. В данной реализации формирование сигналов full_o и empty_o происходит следующим образом:
```Verilog
  assign equal_ptrs  = (wr_ptr == rd_ptr);
  assign same_circle = (wr_ptr_odd_circle == rd_ptr_odd_circle);
  assign empty_o = equal_ptrs & same_circle;
  assign full_o  = equal_ptrs & ~same_circle;
```

В роли сигнала push_i для FIFO выступает сигнал ```s_valid_i```.
А сигналом pop_i является:
```Verilog
  assign pop       = m_valid_o && m_ready_i;
```

#### vc_vr_converter

Необходимо сообщать master-устройству, может ли оно инициировать транзакцию записи. Для этого есть **кредиты**. Если число кредитов не равно нулю, то master может производить запись. Для уведомления ведущего устройства о количестве доступных кредитов существует сигнал s_credit_o. Когда появляется еще один кредит, то сигнал s_credit_o держится в высосокм уровне 1 такт. А кредит появляется, когда слово данных читается из FIFO: ```~push && pop```. Вторым требованием к реализации является возврат кредитов ведущему устройству при снятии сброса. Поэтому логика формирования сигнала s_credit_o следующая:
```Verilog
assign s_credit_o = rst_n ? ~s_valid_i && pop || (cnt < num_of_credits) : 1'b0;

```
