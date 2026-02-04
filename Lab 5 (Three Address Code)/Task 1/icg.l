%{
#include <stdlib.h>
#include <string.h>
#include "icg.tab.h"
%}

%%

[ \t]+    ;
\n        return NEWLINE;

"+="      return PLUS_EQ;
"-="      return MINUS_EQ;
"*="      return MULT_EQ;
"/="      return DIV_EQ;
"%="      return MOD_EQ;
"**="     return POW_EQ;
"//="     return INTDIV_EQ;

"**"      return POW;
"//"      return INTDIV;

"&&"      return AND;
"||"      return OR;
"!"       return NOT;

">="      return GE;
"<="      return LE;
"=="      return EQ;
"!="      return NE;

">"       return GT;
"<"       return LT;
"+"       return '+';
"-"       return '-';
"*"       return '*';
"/"       return '/';
"%"       return '%';
"("       return '(';
")"       return ')';
"="       return '=';

[a-zA-Z][a-zA-Z0-9]* {
    yylval.str = strdup(yytext);
    return ID;
}

[0-9]+    {
    yylval.str = strdup(yytext);
    return NUM;
}

.         return yytext[0];

%%

int yywrap() { 
    return 1;
     }