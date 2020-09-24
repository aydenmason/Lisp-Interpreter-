
%{

%}

/*
 *	Definitions of regular expressions
*/

WSPACE		[ \t\r]+
NEWLINE          \n
LO_ALPHA		[a-z]
HI_ALPHA		[A-Z]
ALPHA			{LO_ALPHA}|{HI_ALPHA}
DIGIT            [0-9]
ALPHANUM		{ALPHA}|{DIGIT}
UNDERSCORE		_

IDENT			({UNDERSCORE}|{ALPHA})({ALPHANUM}|{UNDERSCORE})*

NEG_INTCONST	"-"[0-9]+
POS_INTCONST	("+")?[0-9]+
INTCONST        {NEG_INTCONST}|{POS_INTCONST}

DOUBLE_QUOTE      \"
STRCONST         {DOUBLE_QUOTE}[^\"\n]*{DOUBLE_QUOTE} 

COMMENT           ";".*$      
/*
 *	Tokens
*/
%%

"("			{
			if (OUTPUT_TOKENS)
			  printf("TOKEN: LPAREN    LEXEME: %s\n",
				   yytext);
			return T_LPAREN;
			}
")"			{
			if (OUTPUT_TOKENS)
			  printf("TOKEN: RPAREN    LEXEME: %s\n", 
				   yytext);
			return T_RPAREN;
			}
"+"			{
			if (OUTPUT_TOKENS)
			  printf("TOKEN: ADD       LEXEME: %s\n", 
				   yytext);
			return T_ADD;
			}
"-"			{
			if (OUTPUT_TOKENS)
			  printf("TOKEN: SUB       LEXEME: %s\n",
				   yytext);
			return T_SUB;
			}
"*"			{
			if (OUTPUT_TOKENS)
			  printf("TOKEN: MULT      LEXEME: %s\n", 
			         yytext);
			return T_MULT;
			}
"/"			{
			if (OUTPUT_TOKENS)
			  printf("TOKEN: DIV       LEXEME: %s\n", 
				   yytext);
			return T_DIV;
			}
">"			{
			if (OUTPUT_TOKENS)
			  printf("TOKEN: GT        LEXEME: %s\n", 
			         yytext);
			return T_GT;
			}
">="			{
			if (OUTPUT_TOKENS)
			  printf("TOKEN: GE        LEXEME: %s\n", 
				   yytext);
			return T_GE;
			}
"<"			{
			if (OUTPUT_TOKENS)
			  printf("TOKEN: LT        LEXEME: %s\n", 
			         yytext);
			return T_LT;
			}
"<="			{
			if (OUTPUT_TOKENS)
			  printf("TOKEN: LE        LEXEME: %s\n", 
			         yytext);
			return T_LE;
			}
"="			{
			if (OUTPUT_TOKENS)
			  printf("TOKEN: EQ        LEXEME: %s\n",
			         yytext);
			return T_EQ;
			}
"/="			{
			if (OUTPUT_TOKENS)
			  printf("TOKEN: NE        LEXEME: %s\n", 
			         yytext);
			return T_NE;
			}
"progn"		{
			if (OUTPUT_TOKENS)
			  printf("TOKEN: PROGN     LEXEME: %s\n", 
			         yytext);
			return T_PROGN;
			}
"let*"		{
			if (OUTPUT_TOKENS)
			  printf("TOKEN: LETSTAR   LEXEME: %s\n", 
			         yytext);
			beginScope();
			return T_LETSTAR;
			}
"if"			{
			if (OUTPUT_TOKENS)
			  printf("TOKEN: IF        LEXEME: %s\n", 
			         yytext);
			return T_IF;
			}
"print"		{
			if (OUTPUT_TOKENS)
			  printf("TOKEN: PRINT     LEXEME: %s\n", 
			         yytext);
			return T_PRINT;
			}
"input"		{
			if (OUTPUT_TOKENS)
			  printf("TOKEN: INPUT     LEXEME: %s\n", 
				    yytext);
			return T_INPUT;
			}
"t"			{
			if (OUTPUT_TOKENS)
			  printf("TOKEN: T         LEXEME: %s\n", 
			         yytext);
			return T_T;
			}
"nil"			{
			if (OUTPUT_TOKENS)
			  printf("TOKEN: NIL       LEXEME: %s\n", 
			         yytext);
			return T_NIL;
			}
"and"			{
			if (OUTPUT_TOKENS)
			  printf("TOKEN: AND       LEXEME: %s\n",
			         yytext);
			return T_AND;
			}
"or"			{
			if (OUTPUT_TOKENS)
			  printf("TOKEN: OR        LEXEME: %s\n",
			         yytext);
			return T_OR;
			}
"not"			{
			if (OUTPUT_TOKENS)
			  printf("TOKEN: NOT       LEXEME: %s\n", 
			         yytext);
			return T_NOT;
			}
"exit"		{
			if (OUTPUT_TOKENS)
			  printf("TOKEN: EXIT      LEXEME: %s\n", 
			         yytext);
			return T_EXIT;
			}
{INTCONST}	     {
			if (OUTPUT_TOKENS)
			  printf("TOKEN: INTCONST  LEXEME: %s\n", 
			         yytext);
			yylval.num = atoi(yytext);
			return T_INTCONST;
			}
{STRCONST}	     {
			if (OUTPUT_TOKENS)
			  printf("TOKEN: STRCONST  LEXEME: %s\n",
			         yytext);
			yylval.text = strdup(yytext);
			return T_STRCONST;
			}
{IDENT}		{
			if (OUTPUT_TOKENS)
			  printf("TOKEN: IDENT     LEXEME: %s\n", 
			         yytext);
			yylval.text = strdup(yytext);
			return T_IDENT;
			}
{WSPACE}		{ }
{NEWLINE}       {
                 lineNum++;
                }
{COMMENT}		{ }
.			{
			if (OUTPUT_TOKENS)
			  printf("TOKEN: UNKNOWN   LEXEME: %s\n",
			         yytext);
			return T_UNKNOWN;
			}

%%



