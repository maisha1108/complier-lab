%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern FILE* yyin;
int tcount = 1;
int line = 1;

char* new_temp() {
    char* temp = malloc(10);
    sprintf(temp, "t%d", tcount++);
    return temp;
}
%}

%union {
    char* str;
}

%token <str> ID NUM
%token NEWLINE
%token PLUS_EQ MINUS_EQ MULT_EQ DIV_EQ MOD_EQ POW_EQ INTDIV_EQ
%token OR AND NOT POW INTDIV
%token GT GE LT LE EQ NE

%left OR AND
%left GT LT GE LE EQ NE
%left '+' '-'
%left '*' '/' '%' INTDIV
%right POW
%right NOT UMINUS

%type <str> expr term factor

%%

program: statements;

statements: 
    | statements statement
    ;

statement:
    ID '=' expr NEWLINE {
        printf("%d %s = %s\n", line++, $1, $3);
        free($1); free($3);
    }
    | ID PLUS_EQ expr NEWLINE {
        char* t1 = new_temp();
        printf("%d %s = %s * %s\n", line++, t1, $1, $3);
        printf("%d %s = %s + %s\n", line++, $1, $1, t1);
        free($1); free($3); free(t1);
    }
    | ID MINUS_EQ expr NEWLINE {
        char* t1 = new_temp();
        printf("%d %s = %s * %s\n", line++, t1, $1, $3);
        printf("%d %s = %s - %s\n", line++, $1, $1, t1);
        free($1); free($3); free(t1);
    }
    | ID MULT_EQ expr NEWLINE {
        printf("%d %s = %s * %s\n", line++, $1, $1, $3);
        free($1); free($3);
    }
    | ID DIV_EQ expr NEWLINE {
        printf("%d %s = %s / %s\n", line++, $1, $1, $3);
        free($1); free($3);
    }
    | ID MOD_EQ expr NEWLINE {
        printf("%d %s = %s %% %s\n", line++, $1, $1, $3);
        free($1); free($3);
    }
    | ID POW_EQ expr NEWLINE {
        printf("%d %s = %s ** %s\n", line++, $1, $1, $3);
        free($1); free($3);
    }
    | ID INTDIV_EQ expr NEWLINE {
        printf("%d %s = %s // %s\n", line++, $1, $1, $3);
        free($1); free($3);
    }
    | ID '=' expr {
        printf("%d %s = %s\n", line++, $1, $3);
        free($1); free($3);
    }
    ;

expr:
    expr OR expr {
        char* t = new_temp();
        printf("%d %s = %s || %s\n", line++, t, $1, $3);
        $$ = t;
        free($1); free($3);
    }
    | expr AND expr {
        char* t = new_temp();
        printf("%d %s = %s && %s\n", line++, t, $1, $3);
        $$ = t;
        free($1); free($3);
    }
    | expr GT expr {
        char* t = new_temp();
        printf("%d %s = %s > %s\n", line++, t, $1, $3);
        $$ = t;
        free($1); free($3);
    }
    | expr LT expr {
        char* t = new_temp();
        printf("%d %s = %s < %s\n", line++, t, $1, $3);
        $$ = t;
        free($1); free($3);
    }
    | expr GE expr {
        char* t = new_temp();
        printf("%d %s = %s >= %s\n", line++, t, $1, $3);
        $$ = t;
        free($1); free($3);
    }
    | expr LE expr {
        char* t = new_temp();
        printf("%d %s = %s <= %s\n", line++, t, $1, $3);
        $$ = t;
        free($1); free($3);
    }
    | expr EQ expr {
        char* t = new_temp();
        printf("%d %s = %s == %s\n", line++, t, $1, $3);
        $$ = t;
        free($1); free($3);
    }
    | expr NE expr {
        char* t = new_temp();
        printf("%d %s = %s != %s\n", line++, t, $1, $3);
        $$ = t;
        free($1); free($3);
    }
    | expr '+' expr {
        char* t = new_temp();
        printf("%d %s = %s + %s\n", line++, t, $1, $3);
        $$ = t;
        free($1); free($3);
    }
    | expr '-' expr {
        char* t = new_temp();
        printf("%d %s = %s - %s\n", line++, t, $1, $3);
        $$ = t;
        free($1); free($3);
    }
    | term {
        $$ = $1;
    }
    ;

term:
    term '*' factor {
        char* t = new_temp();
        printf("%d %s = %s * %s\n", line++, t, $1, $3);
        $$ = t;
        free($1); free($3);
    }
    | term '/' factor {
        char* t = new_temp();
        printf("%d %s = %s / %s\n", line++, t, $1, $3);
        $$ = t;
        free($1); free($3);
    }
    | term '%' factor {
        char* t = new_temp();
        printf("%d %s = %s %% %s\n", line++, t, $1, $3);
        $$ = t;
        free($1); free($3);
    }
    | term INTDIV factor {
        char* t = new_temp();
        printf("%d %s = %s // %s\n", line++, t, $1, $3);
        $$ = t;
        free($1); free($3);
    }
    | factor {
        $$ = $1;
    }
    ;

factor:
    factor POW factor {
        char* t = new_temp();
        printf("%d %s = %s ** %s\n", line++, t, $1, $3);
        $$ = t;
        free($1); free($3);
    }
    | '(' expr ')' {
        $$ = $2;
    }
    | ID {
        $$ = $1;
    }
    | NUM {
        $$ = $1;
    }
    | NOT factor {
        char* t = new_temp();
        printf("%d %s = ! %s\n", line++, t, $2);
        $$ = t;
        free($2);
    }
    | '-' factor %prec UMINUS {
        char* t = new_temp();
        printf("%d %s = -%s\n", line++, t, $2);
        $$ = t;
        free($2);
    }
    ;

%%

int main() {
    yyin = fopen("input.txt", "r");
    if (!yyin) return 1;
    yyparse();
    fclose(yyin);
    return 0;
}

int yyerror(char *s) {
    fprintf(stderr, "Error at line %d: %s\n", line, s);
    return 0;
}