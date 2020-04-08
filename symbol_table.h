#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

/*
    The SymbolTable is currently implemented as a Linked List.
    Though it is an inefficient data structure for this pupose,
    we are implementing it as our primary focus is the Parser itself.
*/

#include "term.h"
#include "string.h"

enum ERROR_CODES { SUCCESS, VARIABLE_ALREADY_DECLARED, VARIABLE_NOT_DECLARED, TYPE_MISMATCH };

typedef struct Symbol{
    char* name;
    Term term;
    struct Symbol* next;
}Symbol;


Symbol* createSymbolTable(){
    Symbol* symbol = NULL;
    return symbol;
}

int isSymbolTableEmpty(Symbol *symbolTable){
    if(symbolTable==NULL){
        return 1;
    }
    else{
        return 0;
    }
}

int declareSymbol(Symbol **symbolTable, char* name, Term term) {

    Symbol *newSymbol = (Symbol*)malloc(sizeof(Symbol));
    
    int lengthOfName = strlen(name);
    newSymbol->name = (char*)malloc(sizeof(char)*lengthOfName);
    strcpy(newSymbol->name,name);
	//newSymbol->name = name;
	newSymbol->term = term;
    newSymbol->next = NULL;

    if(*symbolTable==NULL){
        *symbolTable = newSymbol;  
    }
    else{
        Symbol* symbol = *symbolTable;
        while(symbol->next !=NULL){
            if(strcmp(name, symbol->name)==0){
                return VARIABLE_ALREADY_DECLARED;
            }
            symbol = symbol->next;
        }
        if(strcmp(name, symbol->name)==0){
                return VARIABLE_ALREADY_DECLARED;
        }
        symbol->next = newSymbol;
    }
    return SUCCESS;
}

void printSymbolValue(Symbol *symbol){
    switch(symbol->term.dataType){
        case INT_TYPE:
            printf("    %s : (INT) %d\n",symbol->name, symbol->term.int_val);
            break;
        case REAL_TYPE:
            printf("    %s : (REAL) %f\n",symbol->name, symbol->term.real_val);
            break;
        case CHAR_TYPE:
            printf("    %s : (CHAR) %c\n",symbol->name, symbol->term.char_val);
            break;
        case STRING_TYPE:
            printf("    %s : (STRING) %s\n",symbol->name, symbol->term.string_val);
            break;
    }
}

int assignSymbol(Symbol *symbolTable, char* name, Term term) {
    /*
        Returns 0 if variable name not declared
        Returns 1 on success
    */ 

    if(symbolTable==NULL){
        return VARIABLE_NOT_DECLARED; 
    }
    else{
        Symbol* symbol = symbolTable;
        while(symbol->next !=NULL){
            
            if(strcmp(name, symbol->name)==0){
                
                if(symbol->term.dataType != term.dataType){
                    return TYPE_MISMATCH;
                }

                symbol->term = term;
                return SUCCESS;
            }
            symbol = symbol->next;
        }
        if(strcmp(name, symbol->name)==0){

            if(symbol->term.dataType != term.dataType){
                return TYPE_MISMATCH;
            }

            symbol->term = term;
            return SUCCESS;
        }
    }
    return VARIABLE_NOT_DECLARED;

}

int getSymbolTerm(Symbol *symbolTable, char* name, Term *term) {
    /*
        Returns 0 if variable name not declared
        Returns 1 on success
    */ 

    if(symbolTable==NULL){
        return VARIABLE_NOT_DECLARED; 
    }
    else{
        Symbol* symbol = symbolTable;
        while(symbol->next !=NULL){
            if(strcmp(name, symbol->name)==0){
                *term = symbol->term;
                return SUCCESS;
            }
            symbol = symbol->next;
        }
        if(strcmp(name, symbol->name)==0){

            *term = symbol->term;
            return SUCCESS;
        }
    }
    return VARIABLE_NOT_DECLARED;

}


void printAllSymbols(Symbol* symbolTable) {
    printf("Symbol Table: {\n");
	if (symbolTable != NULL) {
		Symbol* symbol;
		symbol = symbolTable;
		while (symbol->next != NULL) {
			printSymbolValue(symbol);
			symbol = symbol->next;
		}
		printSymbolValue(symbol);
        printf("}\n");
	}
	else {
		printf("Symbol Table is empty");
	}
}




/*
    void Test(){
        Symbol* symbolTable = createSymbolTable();

    int success;
    Term *term = (Term*)malloc(sizeof(Term));
    term->dataType = INT_TYPE;
    term->int_val = 10;

    Term *term2 = (Term*)malloc(sizeof(Term));
    term2->dataType = INT_TYPE;
    term2->int_val = 40;

    Term *term3 = (Term*)malloc(sizeof(Term));
    term3->dataType = INT_TYPE;
    term3->int_val = 50;

    Term *term4 = (Term*)malloc(sizeof(Term));
    term4->dataType = CHAR_TYPE;
    term4->char_val = 'b';

    success = declareSymbol(&symbolTable, "A", *term4);
    printf("SUCCESS: %d\n",success);
    success = declareSymbol(&symbolTable, "B", *term2);
    printf("SUCCESS: %d\n",success);
    success = declareSymbol(&symbolTable, "A", *term3);
    printf("SUCCESS: %d\n",success);
    success = declareSymbol(&symbolTable, "ch", *term4);
    printf("SUCCESS: %d\n",success);
    
    printAllSymbols(symbolTable);

    Term *term5 = (Term*)malloc(sizeof(Term));
    term5->dataType = STRING_TYPE;
    term5->char_val = 'n';

    success = assignSymbol(symbolTable, "ch", *term5);
    printf("SUCCESS: %d\n",success);

    printAllSymbols(symbolTable);

    success = getSymbolTerm(symbolTable, "B", term5);
    printf("SUCCESS: %d, %d\n",success, term5->int_val);
    }

*/

#endif