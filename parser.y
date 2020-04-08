%{
#include <stdio.h>
#include <stdlib.h>

#include "term.h"
#include "symbol_table.h"

extern int yylex();
extern FILE *yyin;

void yyerror(char *msg);
void addReduction(char *reductionString);
void printTerm(char* name, struct Term term);

Term evaluate(Term oprnd1, Term oprnd2, char optr);
Term negativeEval(Term term);
void incrementIdValueBy(char* name, int num);

void declare(char* name, enum DataType dtype);
void assign(char* name, Term term);
Term getSTValue(char* name);

extern int yylineno;

Symbol* symbolTable;

%}

%union{
  struct Term value;
  enum DataType dtype;
  char optr;
}

%start prog
%token IF THEN ELSE WHILE ASSIGN NEG COMMA SEMI INT REAL CHAR STRING WRITE INCREMENT DECREMENT

%token <value> ID
%token <value> ILIT
%token <value> RLIT
%token <value> CLIT
%token <value> SLIT

%type <value> expr
%type <value> term
%type <value> const
%type <value> incremental
%type <optr> optr
%type <dtype> dtype
%type <dtype> dec_idlist


%left '-' '+'
%left '*' '/'
%left '%'


%%

prog    :   stmts               { addReduction("prog => stmts\n"); }
;

stmts   :   stmt stmts          { addReduction("prog => stmt stmts\n"); }
        |   /* empty */         { addReduction("prog => empty\n"); }
;

stmt    :   var_decl            { addReduction("stmt => var_decl\n\n");   }
        |   assignment          { addReduction("stmt => assignment\n\n"); }
        |   selection           { addReduction("stmt => selection\n\n");  }
        |   repetition          { addReduction("stmt => repetition\n\n"); }
        |   readwrite           { addReduction("stmt => readwrite\n\n");  }
;

readwrite    :   WRITE ID SEMI        { addReduction("readwrite => WRITE ID SEMI\n"); 
                                        printTerm($2.string_val, getSTValue($2.string_val));  }
;

var_decl    :   dec_idlist SEMI    { addReduction("var_decl => dec_idlist SEMI\n"); }
;

dtype       :   INT             { addReduction("dtype => INT\n");       $<dtype>$ = INT_TYPE ; }
            |   REAL            { addReduction("dtype => REAL\n");      $<dtype>$ = REAL_TYPE ; }
            |   CHAR            { addReduction("dtype => CHAR\n");      $<dtype>$ = CHAR_TYPE ; }
            |   STRING          { addReduction("dtype => STRING\n");    $<dtype>$ = STRING_TYPE ; }
;

dec_idlist  :   dtype ID                { addReduction("dec_idlist => dtype ID\n"); declare($2.string_val, $1); }
            |   dec_idlist COMMA ID     { addReduction("dec_idlist => dec_idlist COMMA ID \n"); declare($3.string_val, $1); }
;

assignment  :   ID ASSIGN expr SEMI         { addReduction("assignment => ID ASSIGN expr SEMI\n"); 
                                              assign($1.string_val, $3); }
            |   incremental SEMI            { addReduction("assignment => incremental SEMI\n"); }
;

selection   :   IF '(' expr ')' THEN block else_part         { addReduction("selection => IF ( expr ) THEN block else_part\n"); }
;

else_part   :   ELSE block           { addReduction("else_part => ELSE block\n"); }
            |   ELSE selection       { addReduction("else_part => ELSE selection \n"); }
            |   /* empty */          { addReduction("else_part => empty \n"); }
;

repetition  :   WHILE '(' expr ')' block          { addReduction("repetition => WHILE ( expr ) block \n"); }
;

block   :   '{' stmts '}'          { addReduction("block => stmts\n"); }
;

expr    :   expr optr expr         { addReduction("expr => expr optr expr \n"); $<value>$ = evaluate($1, $3, $2);   }
        |   term                   { addReduction("expr => term\n");      $<value>$ = $1;                           }
        |   '(' expr ')'           { addReduction("expr => ( expr )\n");  $<value>$ = $2;                           }
;

term    :   ID                     { addReduction("term => ID\n");      $<value>$ = getSTValue($1.string_val);  }
        |   const                  { addReduction("term => const\n");           $<value>$=$1;                   }
        |   '-' term               { addReduction("term => - term\n");          $<value>$=negativeEval($2);     }
        |   '+' term               { addReduction("term => + term\n");          $<value>$=$2;                   }
        |   incremental            { addReduction("term => incremental\n");     $<value>$=$1;                   }      
;

incremental :   INCREMENT ID      { addReduction("incremental => INCREMENT ID\n");
                                    incrementIdValueBy($2.string_val, 1);
                                    $<value>$ = getSTValue($2.string_val);          }
            |   ID INCREMENT      { addReduction("incremental => ID INCREMENT\n");
                                    $<value>$ = getSTValue($1.string_val);
                                    incrementIdValueBy($1.string_val, 1);           }
            |   DECREMENT ID      { addReduction("incremental => DECREMENT ID\n");
                                    incrementIdValueBy($2.string_val, -1);
                                    $<value>$ = getSTValue($2.string_val);          }
            |   ID DECREMENT      { addReduction("incremental => ID INCREMENT\n");
                                    $<value>$ = getSTValue($1.string_val);
                                    incrementIdValueBy($1.string_val, -1);           }
;

const   :   ILIT                   { addReduction("const => const\n"); $<value>$=$1;
                                     /*printTerm("",$1)*/    ;}    

        |   RLIT                   { addReduction("const => RLIT\n"); $<value>$=$1;
                                     /*printTerm("",$1)*/    ;}

        |   CLIT                   { addReduction("const => CLIT\n"); $<value>$=$1; 
                                     /*printTerm("",$1)*/    ;}   

        |   SLIT                   { addReduction("const => SLIT\n"); $<value>$=$1; 
                                     /*printTerm("",$1)*/   ;}   
;

optr    :   '+'                    { addReduction("optr => +\n"); $<optr>$ = '+' ;}
        |   '-'                    { addReduction("optr => -\n"); $<optr>$ = '-' ;}
        |   '*'                    { addReduction("optr => *\n"); $<optr>$ = '*' ;}
        |   '/'                    { addReduction("optr => /\n"); $<optr>$ = '/' ;}
        |   '%'                    { addReduction("optr => %\n"); $<optr>$ = '%' ;}
;


%%

void yyerror(char *msg){
    printf("At Line %d, ",yylineno);
    fprintf(stderr, "%s\n",msg);
    printf("REJECT");
    exit(1);
}

void addReduction(char *reductionString){
    FILE *reductionFptr = fopen("reduction.txt","a");
    fprintf(reductionFptr, reductionString);   
    fclose(reductionFptr); 
}

void printTerm(char *name, Term term){
    switch(term.dataType){
        case INT_TYPE:
            printf("    %s : (INT) %d\n",name, term.int_val)  ;
            break;
        case REAL_TYPE:
            printf("    %s : (REAL) %f\n",name,term.real_val)  ;
            break;
        case CHAR_TYPE:
            printf("    %s : (CHAR) %c\n",name,term.char_val)  ;
            break;
        case STRING_TYPE:
            printf("    %s : (STRING) %s\n",name,term.string_val)  ;
            break;
    }

}


Term evaluate(Term oprnd1, Term oprnd2, char optr){
    
    Term result;
    
    if(oprnd1.dataType != oprnd2.dataType){
        char* errorMsg = (char*)malloc(sizeof(char)*100);
        sprintf(errorMsg, "EXPRESSION PARSING ERROR: Cannot apply '%c' operator on different data types.", optr);
        yyerror(errorMsg);
    } 

    if(oprnd1.dataType == INT_TYPE){
        result.dataType = INT_TYPE;
        switch(optr){
            case '+':
                result.int_val = oprnd1.int_val + oprnd2.int_val;
            break;
            case '-':
                result.int_val = oprnd1.int_val - oprnd2.int_val;
            break;
            case '*':
                result.int_val = oprnd1.int_val * oprnd2.int_val;
            break;
            case '/':
                result.int_val = oprnd1.int_val / oprnd2.int_val;
            break;
            case '%':
                result.int_val = oprnd1.int_val % oprnd2.int_val;
            break;
        }
    }
    else if(oprnd1.dataType == REAL_TYPE){
        result.dataType = REAL_TYPE;
        switch(optr){
            case '+':
                result.real_val = oprnd1.real_val + oprnd2.real_val;
            break;
            case '-':
                result.real_val = oprnd1.real_val - oprnd2.real_val;
            break;
            case '*':
                result.real_val = oprnd1.real_val * oprnd2.real_val;
            break;
            case '/':
                result.real_val = oprnd1.real_val / oprnd2.real_val;
            break;
            case '%':
                yyerror("UNDEFINED_OPERATION: Modulo with two real numbers is undefined.");
            break;
        }
    }
    else if(oprnd1.dataType == CHAR_TYPE){
        result.dataType = CHAR_TYPE;
        switch(optr){
            case '+':
                result.char_val = oprnd1.char_val + oprnd2.char_val;
            break;
            case '-':
                result.char_val = oprnd1.char_val - oprnd2.char_val;
            break;
            case '*':
                result.char_val = oprnd1.char_val * oprnd2.char_val;
            break;
            case '/':
                result.char_val = oprnd1.char_val / oprnd2.char_val;
            break;
            case '%':
                yyerror("UNDEFINED_OPERATION: Modulo with two characters is undefined.");
            break;
        }
    }
    else if(oprnd1.dataType == STRING_TYPE){
        result.dataType = STRING_TYPE;
        int length = strlen(oprnd1.string_val) + strlen(oprnd2.string_val);
        char* str = (char*)malloc(sizeof(char) * (length+1));
        str[0] = '\0';
        switch(optr){
            case '+':
                strcat(str, oprnd1.string_val);
                strcat(str, oprnd2.string_val);
                result.string_val = str;
                /* printf("STRING CONCATANATION: %s\n",result.string_val); */
            break;
            default:
                yyerror("UNDEFINED_OPERATION: Strings can only be concatenated with '+'.");
                break;
        }
    }


    return result;
}

Term negativeEval(Term term){

    Term result;
    if(term.dataType == INT_TYPE){
        result.dataType = INT_TYPE;
        result.int_val = - term.int_val;
    } 
    else if(term.dataType == REAL_TYPE){
        result.dataType = REAL_TYPE;
        result.real_val = - term.real_val;
    } 
    else if(term.dataType == CHAR_TYPE){
        yyerror("EXPRESSION PARSING ERROR: Char cannot be negative.");
    } 
    else if(term.dataType == STRING_TYPE){
        yyerror("EXPRESSION PARSING ERROR: String cannot be negative.");
    } 
    else if(term.dataType == ID_TYPE){
        enum ERROR_CODES success;
        Term *term = (Term*)malloc(sizeof(Term));
        success = getSymbolTerm(symbolTable, term->string_val, term);

        if(success==VARIABLE_NOT_DECLARED){
            yyerror("VARIABLE_NOT_DECLARED: Error while assigning value.");
        }
        result = *term;
    }

    return result;
}

void declare(char* name, enum DataType dtype){
    enum ERROR_CODES success;
    Term *term = (Term*)malloc(sizeof(Term));
    
    term->dataType = dtype;

    success = declareSymbol(&symbolTable, name, *term);
    if(success == VARIABLE_ALREADY_DECLARED){
        yyerror("VARIABLE_ALREADY_DECLARED");
    }
}

void assign(char* name, Term term){
    enum ERROR_CODES success;
    Term *term2 = (Term*)malloc(sizeof(Term));
    term2->dataType = term.dataType;
    switch(term2->dataType){
        case INT_TYPE:
            term2->int_val = term.int_val;
        break;
        case REAL_TYPE:
            term2->real_val = term.real_val;
        break;
        case CHAR_TYPE:
            term2->char_val = term.char_val;
        break;
        case STRING_TYPE:
            term2->string_val = term.string_val;
        break;  
    }

    success = assignSymbol(symbolTable, name, *term2);
    if(success == TYPE_MISMATCH){
        yyerror("TYPE_MISMATCH: Error while assigning value.");
    }
    else if(success == VARIABLE_NOT_DECLARED){
        yyerror("VARIABLE_NOT_DECLARED: Error while assigning value.");
    }
}

Term getSTValue(char* name){
    enum ERROR_CODES success;

    Term *term = (Term*)malloc(sizeof(Term));
    success = getSymbolTerm(symbolTable, name, term);

    if(success==VARIABLE_NOT_DECLARED){
        yyerror("VARIABLE_NOT_DECLARED: Error while assigning value.");
    }

    return *term;
}

void incrementIdValueBy(char* name, int num){
    Term stTerm = getSTValue(name);

    if(stTerm.dataType!=INT_TYPE){
        yyerror("INVALID_TYPE: Can't increment a non integer value.");
    }

    stTerm.int_val = stTerm.int_val + num;
    assign(name, stTerm);
}

int main(int argc, char *argv[]){
    
    /*CREATING GLOBAL SYMBOLTABLE*/
    symbolTable = createSymbolTable();

    /* Clearing the Reduciton output file */
    FILE *reductionFptr = fopen("reduction.txt","w");
    fclose(reductionFptr); 

    if(argc!=2){
        printf("Usage: [program] [fileName]");
        return 0;
    }
    yyin=fopen(argv[1],"r");
    yyparse();

    //printAllSymbols(symbolTable);

    printf("ACCEPT\n");
    return 0;
}
