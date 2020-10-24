# Metaprogramming

### 1. Turing Machine (*TM*) interpreter 
  - [__`Turing_machine_interpreter/turing.rkt`__](https://github.com/ZhekehZ/Metaprogramming/tree/master/Turing_machine_interpreter/turing.rkt) --- *TM* interpreter in *Racket* and tests for it
  - [__`FlowChart_interpreter/turing.rkt`__](https://github.com/ZhekehZ/Metaprogramming/tree/master/FlowChart_interpreter/turing.rkt) --- *TM* interpreter in *FlowChart*  *(for testing the flowchart interpreter only)*  
    **Provides** 
     - *`tm-int`* --- *TM* interpreter implementation
  - [__`Mix_algorithm/Test_cases/turing.rkt`__](https://github.com/ZhekehZ/Metaprogramming/blob/master/Mix_algorithm/Test_cases/turing.rkt) --- *TM* interpreter in *FlowChart* *(Mix-friendly implementation)*  
    **Provides**
     - *`tm-int`* --- *TM* interpreter implementation
     - *`tm-division`* --- *TM* varables division for *Mix* algorithm
     - *`tm-program`* --- simple *TM* program for tests
     - *`run-tm-unit-tests`* --- *`tm-plogram`* unit tests runner

### 2. FlowChart interpreter    
  - [__`FlowChart_interpreter/flowchart.rkt`__](https://github.com/ZhekehZ/Metaprogramming/blob/master/FlowChart_interpreter/flowchart.rkt) --- *FlowChart* interpreter in *Racket*  
    **Provides**
     - *`fc-int`* --- *FlowChart* interpreter implementation
     - *`eval-ns`* --- expression evaluator in the *`fc-int`* namespace
     - *`eval-expr`* --- expression evaluator in the *`fc-int`* namespace and given environment
     - *`fc-define-func`* --- *`fc-int`* namespace extensor
  - [__`FlowChart_on_FlowChart/flowchart-int.rkt`__](https://github.com/ZhekehZ/Metaprogramming/blob/master/FlowChart_on_FlowChart/flowchart-int.rkt) --- *FlowChart* interpreter in *FlowChart*  
    **Provides**
     - *`fc-int-fc`* --- *FlowChart* interpreter implementation
     - *`fc-division`* --- *`fc-int-fc`* variables division for *Mix* algorithm
  - [__`FlowChart_on_FlowChart/flowchart-int-tests.rkt`__](https://github.com/ZhekehZ/Metaprogramming/blob/master/FlowChart_on_FlowChart/flowchart-int-tests.rkt) --- tests for *`fc-int-fc`*

### 3. Mix algorithm
  - [__`Mix_algorithm/mix.rkt`__](https://github.com/ZhekehZ/Metaprogramming/blob/master/Mix_algorithm/mix.rkt) --- *Mix* algorithm in *FlowChart*  
    **Provides**
     - *`mix`* --- *Mix* algorithm implementation
     - *`mix-division`* --- *`mix`* variables division for *`mix`*
 - [__`Mix_algorithm/pretty-printer.rkt`__](https://github.com/ZhekehZ/Metaprogramming/blob/master/Mix_algorithm/pretty-printer.rkt) --- pretty-printer for *`mix`* output  
    **Provides**
      - *`pretty-print`* --- *`mix`* output converter
      - *`pretty-display`* --- *`mix`* output printer
 - [__`Mix_algorithm/mix-extensions-for-flowchart-interpreter.rkt`__](https://github.com/ZhekehZ/Metaprogramming/blob/master/Mix_algorithm/mix-extensions-for-flowchart-interpreter.rkt) --- some *`fc-int`* namespace extensions  
   > **Extends *fc-int* namespace with**:
   >  - *`reduce`* --- partial expression evaluator in a given environment
   >  - *`evaluate`* --- see *`eval-expr`* in flowchart interpreter
   >  - *`get-new-read-statement`* --- removes static variables from read expression
   >  - *`static?`* --- checks whether the expression can be fully evaluated in the current context
   >  - *`find-blocks-in-pending`* --- provides *Blocks-in-pending* optimization
   >  - *`get-LVA-data`* --- provides [*Live Variable Analysis*](https://en.wikipedia.org/wiki/Live_variable_analysis)
   >  - *`filter-live`* --- filters out dead static variables from the environment

 ### 4. Futamura Projections
  - [__`Futamura_projections/first.rkt`__](https://github.com/ZhekehZ/Metaprogramming/blob/master/Mix_algorithm/Futamura_projections/first.rkt) --- 1st Futamura projection  
         *`mix (tm-int, tm-program)`*
  - [__`Futamura_projections/second.rkt`__](https://github.com/ZhekehZ/Metaprogramming/blob/master/Mix_algorithm/Futamura_projections/second.rkt) --- 2nd Futamura projection  
        *`mix (mix, tm-int)`*
  - [__`Futamura_projections/third.rkt`__](https://github.com/ZhekehZ/Metaprogramming/blob/master/Mix_algorithm/Futamura_projections/third.rkt) --- 3rd Futamura projection  
        *`mix (mix, mix)`* 
  - [__`FlowChart_on_FlowChart/flowchart-mix-id.rkt`__](https://github.com/ZhekehZ/Metaprogramming/blob/master/FlowChart_on_FlowChart/flowchart-mix-id.rkt) --- *FlowChart* identity compiler, result of  
        *`mix (mix, mix) (fc-int-fc)`*
