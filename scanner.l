
%option yylineno

%{
#include<string.h>
#include "term.h"
#include"parser.tab.h"

extern void yyerror(char *msg);

%}


ILIT [0-9]+
RLIT (([0-9]*\.[0-9]+)|([0-9]+\.)) 
SLIT ["](([\\]["])|([^"]))*["]
CLIT '(([\\]['])|([^']))+'
ID [_a-zA-Z][_a-zA-Z0-9]*

%%

if              { return(IF)    ; }
then            { return(THEN)  ; }
else            { return(ELSE)  ; }
while           { return(WHILE) ; }

write           { return(WRITE) ; }

int             { return(INT)   ; }
real            { return(REAL)  ; }
char            { return(CHAR)  ; }
string          { return(STRING); }

":="            { return(ASSIGN); }
","             { return(COMMA) ; }
";"             { return(SEMI)  ; }
"++"            { return(INCREMENT); }
"--"            { return(DECREMENT); }

{ID}            { yylval.value.dataType = ID_TYPE; 
                  int length = strlen(yytext);
                  yylval.value.string_val = (char*)malloc(sizeof(char)* (length) );
                  strcpy(yylval.value.string_val, yytext);
                  return(ID)    ; }

{ILIT}          { yylval.value.int_val = atoi(yytext);
                  yylval.value.dataType = INT_TYPE;
                  return(ILIT)  ; }

{RLIT}          { yylval.value.real_val = atof(yytext);
                  yylval.value.dataType = REAL_TYPE;
                  return(RLIT)  ; }

{CLIT}          { yylval.value.char_val = yytext[1];
                  yylval.value.dataType = CHAR_TYPE;
                  return(CLIT)  ; }

{SLIT}          { yylval.value.dataType = STRING_TYPE;
                  int length = strlen(yytext);
                  yylval.value.string_val = (char*)malloc(sizeof(char)* (length-2) );
                  strncpy( yylval.value.string_val, yytext+1 , length-2 );
                  yylval.value.string_val[length-2] = '\0';
                  return(SLIT)  ; }

[\t\f\v\n ]     { ; }


{ILIT}{ID}|{RLIT}{ID}|{CLIT}{ID}|{SLIT}{ID}     {   char* errorMsg = (char*)malloc(sizeof(char)*100);
                                                    sprintf(errorMsg, "LEXER_ERROR: Unrecognized TOKEN: %s", yytext);
                                                    yyerror(errorMsg); 
                                                }  

.               {  return yytext[0];  }
                                          
%%


int yywrap() {}

