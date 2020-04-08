# Interpreter

A sample interpreter that we wrote as part of our assignment for CSE426 (Compiler Construction) at North South University.
## Description
The interpreter recognizes a language that has 4 data types:
1. Integer
2. Real
3. Character
4. String

The interpreter can perform string concatenations, mathematical evaluations and display the value of a variable.

# Usage

### Requirements
* [Bison](https://www.gnu.org/software/bison/)
* [Flex](https://sourceforge.net/projects/flex/)
* [C compiler](http://mingw.org/) (We are using MinGW)

Execute these commands sequentially in your Bash program.

```
bison -dv parser.y
flex scanner.l
gcc parser.tab.c lex.yy.c -o Main
./Main input.txt
```

# Context Free Grammar

The language follows the following context free grammar which is defined in [parser.y](parser.y).
```
prog → stmts
stmts → stmt stmts | ɛ
stmt → var_decl | assignment | selection | repetition | readwrite
readwrite → WRITE ID SEMI
var_decl → dec_idlist SEMI
dec_idlist → dtype ID | dec_idlist COMMA ID
dtype → INT | REAL | CHAR | STRING
assignment →ID ASSIGN expr SEMI | incremental SEMI
selection → IF (expr) THEN block else_part
else_part → ELSE block | ELSE selection | ɛ
repetition → while ( expr ) block
block → { stmts }
expr → expr optr expr | term | (expr)
term → ID | const | + term | - term | incremental
incremental → INCREMENT ID | ID INCREMENT | DECREMENT ID | ID DECREMENT
const → ILIT| RLIT| CLIT| SLIT
optr → +| - | * | / | %
```

### Example
An example of the content in the [input.txt](input.txt) file.
```
int a;
int b;
int temp;

a := 10;
b := 20;
write a;
write b;

temp := a;
a := b;
b := temp;
write a;
write b;
```

**Output:**
```
    a : (INT) 10
    b : (INT) 20
    a : (INT) 20
    b : (INT) 10
```


## Functionality

Implemented compiler functionality following the C89 Spec.

- [x] Store variable values
- [x] Perform mathematical expressions
- [x] Output results
- [x] Show errors
- [ ] Evaluate integers with reals
- [ ] Perform selections (IF ELSE)
- [ ] Perform repititions (WHILE)
