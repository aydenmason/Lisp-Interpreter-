
%{
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <string>
#include <stack>
#include <cstring>
#include "SymbolTable.h"
using namespace std;

// Classification for operators
#define ARITHMETIC_OP	1   
#define LOGICAL_OP   	2
#define RELATIONAL_OP	3
#define PLUS 12
#define MULT 13
#define DIV 14
#define SUB 15
#define OR 16
#define AND 17 
#define LE 18
#define GE 19
#define LT 20
#define GT 21
#define NE 22
#define EQ 23
#define NOT 24
#define TRUE true
#define nil false
// Error messages
#define UNDEFINED_IDENT "Undefined identifier"
#define MULTIPLY_DEFINED_IDENT "Multiply defined identifier"
#define MUST_BE_INTEGER1 "Arg 1 must be integer"
#define MUST_BE_INTEGER2 "Arg 2 must be integer"
#define MUST_BE_STRING2 "Arg 2 must be string"
#define MUST_BE_INT_OR_STR1 "Arg 1 must be integer or string"
#define MUST_BE_INT_OR_STR2 "Arg 2 must be integer or string"

// Control output (1 to produce designated output; 0 otherwise)
#define OUTPUT_TOKENS 0
#define OUTPUT_PRODUCTIONS 0
#define OUTPUT_ST_MGT 1

// Global variables
int lineNum = 1;
//char* input = [];
stack<SYMBOL_TABLE> scopeStack;    // stack of scope hashtables

// Function prototypes
bool isIntCompatible(const int theType);
bool isStrCompatible(const int theType);
bool isIntOrStrCompatible(const int theType);

void beginScope();
void endScope();
void cleanUp();
void prepareToTerminate();
void bail();
TYPE_INFO findEntryInAnyScope(const string theName);
void printRule(const char*, const char*);

int yyerror(const char* s) 
{
  printf("Line %d: %s\n", lineNum, s);
  bail();
}

extern "C" {
    int yyparse(void);
    int yylex(void);
    int yywrap() {return 1;}
}

%}

%union {
  char* text;
  int num;
  TYPE_INFO typeInfo;
  int opType;
};

/*
 *	Token declarations
*/
%token  T_LPAREN T_RPAREN 
%token  T_IF T_LETSTAR T_PRINT T_INPUT
%token  T_ADD  T_SUB  T_MULT  T_DIV T_EXIT T_PROGN
%token  T_LT T_GT T_LE T_GE T_EQ T_NE T_AND T_OR T_NOT	 
%token  T_INTCONST T_STRCONST T_T T_NIL T_IDENT T_UNKNOWN

%type <text> T_IDENT T_STRCONST
%type <typeInfo> N_EXPR N_PARENTHESIZED_EXPR N_ARITHLOGIC_EXPR  
%type <typeInfo> N_CONST N_IF_EXPR N_PRINT_EXPR N_INPUT_EXPR 
%type <typeInfo> N_LET_EXPR N_EXPR_LIST 
%type <typeInfo> N_PROGN_OR_USERFUNCTCALL N_FUNCT_NAME
%type <typeInfo> N_ACTUAL_PARAMS  
%type <num>  T_INTCONST
%type <opType> N_BIN_OP N_ARITH_OP N_LOG_OP N_REL_OP T_ADD T_MULT N_UN_OP 
%type <opType> T_DIV T_SUB T_AND T_OR T_NOT T_LT T_GT T_GE T_LE T_EQ T_NE


/*
 *	Starting point.
 */
%start  N_START

/*
 *	Translation rules.
 */
%%
N_START		: // epsilon 
			{
			printRule("START", "epsilon");
			}
			| N_START N_EXPR
			{
			printRule("START", "START EXPR");
			
			switch ($2.type)
			{
			case INT : 
			printf("\n---- Completed parsing ----\n\n");
			printf("\nValue of the expression is: %d\n", $2.valINT);
			break;
			case STR :
			printf("\n---- Completed parsing ----\n\n");
			printf("\nValue of the expression is: %s\n", $2.valSTR);
			break;
			
			case BOOL : printf("\n---- Completed parsing ----\n\n");
			printf("\nValue of the expression is: %s\n", $2.valBOOL == false ? "nil" : "t");
			break;
			
			
			default : cout << "UNKNOWN";
			}
			
			}
			;
N_EXPR		: N_CONST
			{
			printRule("EXPR", "CONST");
			$$.type = $1.type; 
			if($1.type == STR){
				$$.valSTR = $1.valSTR;
			}
			if($1.type == INT){
				$$.valINT = $1.valINT;

			}
			if($1.type == BOOL){
			$$.valBOOL = $1.valBOOL;
			}
			
			}
                | T_IDENT
                {
			printRule("EXPR", "IDENT");
                string ident = string($1);
                TYPE_INFO exprTypeInfo = 
						findEntryInAnyScope(ident);
                if (exprTypeInfo.type == UNDEFINED) 
                  yyerror(UNDEFINED_IDENT);
                $$.type = exprTypeInfo.type; 
				switch(exprTypeInfo.type){
					case(STR):
						$$.valSTR = exprTypeInfo.valSTR;
						break;
					case(INT):
						$$.valINT = exprTypeInfo.valINT;
						break;
					case(BOOL):
						$$.valBOOL = exprTypeInfo.valBOOL;
						break;
				}
				
			}
                | T_LPAREN N_PARENTHESIZED_EXPR T_RPAREN
                {
			printRule("EXPR", "( PARENTHESIZED_EXPR )");
			$$.type = $2.type; 
			switch($2.type){
					case(STR):
						$$.valSTR = $2.valSTR;
					
						break;
					case(INT):
						$$.valINT = $2.valINT;
						
						break;
					case(BOOL):
						$$.valBOOL = $2.valBOOL;
						break;
				}
			}
			;
N_CONST		: T_INTCONST
			{
			printRule("CONST", "INTCONST");
                $$.type = INT; 
				$$.valINT= $1;
			}
                | T_STRCONST
			{
			printRule("CONST", "STRCONST");
                $$.type = STR; 
				$$.valSTR = $1;
			}
                | T_T
                {
			printRule("CONST", "t");
                $$.type = BOOL; 
				$$.valBOOL = true;
			}
                | T_NIL
                {
			printRule("CONST", "nil");
			$$.type = BOOL; 
			$$.valBOOL = false;
			}
			;
N_PARENTHESIZED_EXPR	: N_ARITHLOGIC_EXPR 
				{
				printRule("PARENTHESIZED_EXPR",
                                "ARITHLOGIC_EXPR");
				$$.type = $1.type; 
				switch($1.type){
					case(STR):
						$$.valSTR = $1.valSTR;
						break;
					case(INT):
						$$.valINT = $1.valINT;
						break;
					case(BOOL):
						$$.valBOOL = $1.valBOOL;
						break;
				}
				}
				| N_IF_EXPR 
				{
				printRule("PARENTHESIZED_EXPR",
                               "IF_EXPR");
				$$.type = $1.type; 
				switch($1.type){
					case(STR):
						$$.valSTR = $1.valSTR;
						break;
					case(INT):
						$$.valINT = $1.valINT;
						break;
					case(BOOL):
						$$.valBOOL = $1.valBOOL;
						break;
				}
				}
				| N_LET_EXPR 
				{
				printRule("PARENTHESIZED_EXPR", 
                                "LET_EXPR");
				$$.type = $1.type; 
				switch($1.type){
					case(STR):
						$$.valSTR = $1.valSTR;
						break;
					case(INT):
						$$.valINT = $1.valINT;
						break;
					case(BOOL):
						$$.valBOOL = $1.valBOOL;
						break;
				}
				}
				| N_PRINT_EXPR 
				{
				printRule("PARENTHESIZED_EXPR", 
					    "PRINT_EXPR");
				$$.type = $1.type; 
				switch($1.type){
					case(STR):
						$$.valSTR = $1.valSTR;
						break;
					case(INT):
						$$.valINT = $1.valINT;
						break;
					case(BOOL):
						$$.valBOOL = $1.valBOOL;
						break;
				}
				}
				| N_INPUT_EXPR 
				{
				printRule("PARENTHESIZED_EXPR",
					    "INPUT_EXPR");
				$$.type = $1.type; 
				switch($1.type){
					case(STR):
						$$.valSTR = $1.valSTR;
						break;
					case(INT):
						$$.valINT = $1.valINT;
						break;
					case(BOOL):
						$$.valBOOL = $1.valBOOL;
						break;
				}
				}
                     | N_PROGN_OR_USERFUNCTCALL 
				{
				printRule("PARENTHESIZED_EXPR",
				          "PROGN_OR_USERFUNCTCALL");
				$$.type = $1.type; 
				switch($1.type){
					case(STR):
						$$.valSTR = $1.valSTR;
						break;
					case(INT):
						$$.valINT = $1.valINT;
						break;
					case(BOOL):
						$$.valBOOL = $1.valBOOL;
						break;
				}
				}
				| T_EXIT
				{
				printRule("PARENTHESIZED_EXPR",
				          "EXIT");
				bail();
				}
				;
N_PROGN_OR_USERFUNCTCALL : N_FUNCT_NAME N_ACTUAL_PARAMS
				{
				printRule("PROGN_OR_USERFUNCTCALL ",
				          "FUNCT_NAME ACTUAL_PARAMS");
				// Special case if it was epsilon
				if ($2.type == NOT_APPLICABLE){
				  $$.type = BOOL;
				  $$.valBOOL = nil;
				}

				else $$.type = $2.type;
				switch($2.type){
					case(STR):
						$$.valSTR = $2.valSTR;
						break;
					case(INT):
						$$.valINT = $2.valINT;
						break;
					case(BOOL):
						$$.valBOOL = $2.valBOOL;
						break;
				}
				}
				;
N_FUNCT_NAME		: T_PROGN
				{
				printRule("FUNCT_NAME", 
				          "PROGN");
				$$.type = NOT_APPLICABLE; 
				}
                     	;
N_ACTUAL_PARAMS		: N_EXPR_LIST
				{
				printRule("ACTUAL_PARAMS", 
				          "EXPR_LIST");
				$$.type = $1.type;
				$$.valBOOL = $1.valBOOL ;
				$$.valINT = $1.valINT;
				$$.valSTR = $1.valSTR;
				}
				| // epsilon
				{
				printRule("ACTUAL_PARAMS", 
				          "EPSILON");
				$$.type = NOT_APPLICABLE; 
			
				}
				;
N_ARITHLOGIC_EXPR	: N_UN_OP N_EXPR
				{
				printRule("ARITHLOGIC_EXPR", 
				          "UN_OP EXPR");
				$$.type = BOOL; 
				if($1 == NOT){
					if($2.valBOOL == TRUE){
						$$.valBOOL = nil;
					}
					else{
						$$.valBOOL = TRUE;
					}
				}
				}

				| N_BIN_OP N_EXPR N_EXPR
				{
				printRule("ARITHLOGIC_EXPR", 
				          "BIN_OP EXPR EXPR");
				$$.type = BOOL;
				
                if($1 == PLUS || $1 == SUB || $1 == DIV || $1 == MULT){

				  $$.type = INT;
				  if (!isIntCompatible($2.type))
                          yyerror(MUST_BE_INTEGER1);
				  if (!isIntCompatible($3.type))
                          yyerror(MUST_BE_INTEGER2);
				if ($1 == PLUS){
					$$.valINT = $2.valINT + $3.valINT;
				}
				if($1 == SUB){
					$$.valINT = $2.valINT - $3.valINT;
				}
				if($1 == MULT){
					$$.valINT = $2.valINT * $3.valINT;
				}
				if($1 == DIV){
					if($3.valINT == 0){
						yyerror("Attempted division by zero");
					}
					$$.valINT = $2.valINT / $3.valINT;
				}}
				 

				if($1 == AND || $1 == OR){
					if($1 == AND){
						if($2.valBOOL == nil && $3.type != nil){
							$$.valBOOL = nil;
						}
						else{
							$$.valBOOL = TRUE;
						}
					}
					if($1 == OR){
						if($2.valBOOL != nil || $3.type != nil){
							$$.valBOOL = TRUE;
						}
						else{
							$$.valBOOL = nil;
						}
					}
				}

                if($1 == LE || $1 == GE || $1 == LT || $1 == GT || $1 == EQ || $1 == NE){
				  if (!isIntOrStrCompatible($2.type)) 
                          yyerror(MUST_BE_INT_OR_STR1);
				  if (!isIntOrStrCompatible($3.type)) 
                          yyerror(MUST_BE_INT_OR_STR2); 
				  if (isIntCompatible($2.type) &&
                            !isIntCompatible($3.type)) 
                          yyerror(MUST_BE_INTEGER2);
				  if (isStrCompatible($2.type) &&
                           !isStrCompatible($3.type)) 
				     yyerror(MUST_BE_STRING2);
				if($2.type == STR && $3.type == STR){
				if($1 == LT){
					$2.valSTR < $3.valSTR ? $$.valBOOL = TRUE : $$.valBOOL = nil;
				}
				if($1== GT){
					$2.valSTR > $3.valSTR ? $$.valBOOL = TRUE :$$.valBOOL =  nil;
				}	
				if($1 == LE){
					$2.valSTR <=$3.valSTR ? $$.valBOOL = TRUE : $$.valBOOL = nil;
				}	
				if($1 == GE){
					$2.valSTR >= $3.valSTR ? $$.valBOOL = TRUE :$$.valBOOL =  nil;
				}
				if($1 == NE){
					$2.valSTR != $3.valSTR ? $$.valBOOL = TRUE: $$.valBOOL = nil;
				}
				if($1 ==EQ){
					$2.valSTR == $2.valSTR ? $$.valBOOL = TRUE : $$.valBOOL = nil;
				}
				}
				if($2.type == INT  && $3.type == INT){
				if($1 == LT){
					$2.valINT < $3.valINT ? $$.valBOOL = TRUE : $$.valBOOL = nil;
				}
				if($1 == GT){
					$2.valINT > $3.valINT ? $$.valBOOL = TRUE :$$.valBOOL =  nil;
				}	
				if($1 == LE){
					$2.valINT <=$3.valINT ? $$.valBOOL = TRUE : $$.valBOOL = nil;
				}	
				if($1 == GE){
					$2.valINT >= $3.valINT ? $$.valBOOL = TRUE :$$.valBOOL =  nil;
				}
				if($1 == NE){
					$2.valINT != $3.valINT ? $$.valBOOL = TRUE: $$.valBOOL = nil;
				}
				if($1 ==EQ){
					$2.valINT == $2.valINT ? $$.valBOOL = TRUE : $$.valBOOL = nil;
				}
				}
                }  // end switch
				}
				;
N_IF_EXPR    	: T_IF N_EXPR N_EXPR N_EXPR
			{
			printRule("IF_EXPR", "if EXPR EXPR EXPR");
                $$.type = $3.type;
				if($2.valBOOL == nil){
					switch($4.type){
					case(STR):
						$$.valSTR = $4.valSTR;
						break;
					case(INT):
						$$.valINT = $4.valINT;
						break;
					case(BOOL):
						$$.valBOOL = $4.valBOOL;
						break;
				}
				}
				else{
					switch($3.type){
					case(STR):
						$$.valSTR = $3.valSTR;
						break;
					case(INT):
						$$.valINT = $3.valINT;
						break;
					case(BOOL):
						$$.valBOOL = $3.valBOOL;
						break;
				}
				}	
			}
			;
N_LET_EXPR      : T_LETSTAR T_LPAREN N_ID_EXPR_LIST T_RPAREN 
                  N_EXPR
			{
			
                $$.type = $5.type;
				$$.valSTR = $5.valSTR; 
				$$.valINT = $5.valINT;
				$$.valBOOL = $5.valBOOL;
				
			}
			;
N_ID_EXPR_LIST  : /* epsilon */
			{
			printRule("ID_EXPR_LIST", "epsilon");
			}
                | N_ID_EXPR_LIST T_LPAREN T_IDENT N_EXPR T_RPAREN 
			{
			printRule("ID_EXPR_LIST", 
                          "ID_EXPR_LIST ( IDENT EXPR )");
			string lexeme = string($3);
			TYPE_INFO exprTypeInfo = $4;
		
			bool success = scopeStack.top().addEntry
                                (SYMBOL_TABLE_ENTRY(lexeme,
									 exprTypeInfo, exprTypeInfo.valINT, exprTypeInfo.valSTR, exprTypeInfo.valBOOL));
			if (! success) 
                  yyerror(MULTIPLY_DEFINED_IDENT);
			}
			;
N_PRINT_EXPR    : T_PRINT N_EXPR
			{
			printRule("PRINT_EXPR", "print EXPR");
                $$.type = $2.type;
				switch($2.type){
					case(STR):
						$$.valSTR = $2.valSTR;
						printf("%s\n",$2.valSTR);
						break;
					case(INT):
						$$.valINT = $2.valINT;
						printf("%d\n",$2.valINT);
						break;
					case(BOOL):
						$$.valBOOL = $2.valBOOL;
						printf("%d\n",$2.valBOOL);
						
						break;
				}
			}
			;
N_INPUT_EXPR    : T_INPUT
			{
			printRule("INPUT_EXPR", "input");
			char buffer[256];
			cin.getline(buffer,256);
			if(isdigit(buffer[0]) || (buffer[0] == '+') || (buffer[0] == '-')){
				$$.type = INT;
				$$.valINT = atoi(buffer);
				$$.valSTR = strdup("");
				$$.valBOOL = false;
			}
			else{
				$$.type = STR;
				$$.valINT = 0;
				$$.valSTR = strdup(buffer);
				$$.valBOOL = false;
			}
			}
			;
N_EXPR_LIST     : N_EXPR N_EXPR_LIST  
			{
			printRule("EXPR_LIST", "EXPR EXPR_LIST");
			$$.type = $2.type;
			$$.valBOOL = $2.valBOOL;
			$$.valSTR = $2.valSTR;
			$$.valINT = $2.valINT;
			}
                | N_EXPR
			{
			printRule("EXPR_LIST", "EXPR");
			$$.type = $1.type;
			switch($1.type){
					case(STR):
						$$.valSTR = $1.valSTR;
						break;
					case(INT):
						$$.valINT = $1.valINT;
						break;
					case(BOOL):
						$$.valBOOL = $1.valBOOL;
						break;
				}
			}
			;
N_BIN_OP	     : N_ARITH_OP
			{
			printRule("BIN_OP", "ARITH_OP");
			$$ = $1;
		
			}
			|
			N_LOG_OP
			{
			printRule("BIN_OP", "LOG_OP");
			$$ = $1;
			}
			|
			N_REL_OP
			{
			printRule("BIN_OP", "REL_OP");
			$$ = $1;
			}
			;
N_ARITH_OP	     : T_ADD
			{
			printRule("ARITH_OP", "+");
			$$ = PLUS;
			}
                | T_SUB
			{
			printRule("ARITH_OP", "-");
			$$ = SUB;
			}
			| T_MULT
			{
			printRule("ARITH_OP", "*");
			$$ = MULT;
			}
			| T_DIV
			{
			printRule("ARITH_OP", "/");
			$$ = DIV;
			}
			;
N_REL_OP	     : T_LT
			{
			printRule("REL_OP", "<");
			$$ = LT;
			}	
			| T_GT
			{
			printRule("REL_OP", ">");
			$$ = GT;
			}	
			| T_LE
			{
			printRule("REL_OP", "<=");
			$$ = LE;
			}	
			| T_GE
			{
			printRule("REL_OP", ">=");
			$$ = GE;	
			}	
			| T_EQ
			{
			printRule("REL_OP", "=");
			$$ = EQ;	
			}
			| T_NE
			{
			printRule("REL_OP", "/=");
			$$ = NE;	
			}
			;	
N_LOG_OP	     : T_AND
			{
			printRule("LOG_OP", "and");
			$$ = AND;
			}	
			| T_OR
			{
			printRule("LOG_OP", "or");
			$$ = OR;
			}
			;
N_UN_OP	     : T_NOT
			{
			printRule("UN_OP", "not");
			$$ = NOT;
			}
			;
%%

#include "lex.yy.c"
extern FILE *yyin;

bool isIntCompatible(const int theType) 
{
  return((theType == INT) || (theType == INT_OR_STR) ||
         (theType == INT_OR_BOOL) || 
         (theType == INT_OR_STR_OR_BOOL));
}

bool isStrCompatible(const int theType) 
{
  return((theType == STR) || (theType == INT_OR_STR) ||
         (theType == STR_OR_BOOL) || 
         (theType == INT_OR_STR_OR_BOOL));
}

bool isIntOrStrCompatible(const int theType) 
{
  return(isStrCompatible(theType) || isIntCompatible(theType));
}

void printRule(const char* lhs, const char* rhs) 
{
  if (OUTPUT_PRODUCTIONS)
    printf("%s -> %s\n", lhs, rhs);
  return;
}

void beginScope() 
{
  scopeStack.push(SYMBOL_TABLE());
 
}

void endScope() 
{
  scopeStack.pop();
  
}

TYPE_INFO findEntryInAnyScope(const string theName) 
{
  TYPE_INFO info = {UNDEFINED};
  if (scopeStack.empty( )) return(info);
  info = scopeStack.top().findEntry(theName);
  if (info.type != UNDEFINED)
    return(info);
  else { // check in "next higher" scope
	   SYMBOL_TABLE symbolTable = scopeStack.top( );
	   scopeStack.pop( );
	   info = findEntryInAnyScope(theName);
	   scopeStack.push(symbolTable); // restore the stack
	   return(info);
  }
}

void cleanUp() 
{
  if (scopeStack.empty()) 
    return;
  else 
  {
    scopeStack.pop();
    cleanUp();
  }
}

void prepareToTerminate()
{
  cleanUp();
  cout << endl << "Bye!" << endl;
}

void bail()
{
  prepareToTerminate();
  exit(1);
}

int main(int argc, char** argv) 
{
  if(argc < 2){
	printf("You must specify a file in the command line!\n");
	exit(1);
  }
  yyin = fopen(argv[1],"r");
  do {
	yyparse();
  } while (!feof(yyin));

  prepareToTerminate();
  return 0;
}
