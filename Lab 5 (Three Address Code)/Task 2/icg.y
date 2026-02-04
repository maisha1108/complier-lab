%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern FILE* yyin;
extern int yylex(void);

void yyerror(const char* s);
int yyparse();

int temp_counter = 0;
int output_line = 1;
char* new_temp();

%}

%union {
    char* str;
}

%token <str> ID NUM
%token SQRT POW LOG EXP SIN COS TAN ABS
%token NEWLINE

%left '+' '-'
%left '*' '/' '%'
%right UMINUS

%type <str> expr term factor func_call

%%

program:
    statement_list
    ;

statement_list:
    statement
    | statement_list statement
    ;

statement:
    ID '=' expr NEWLINE {
        printf("%d %s = %s\n", output_line, $1, $3);
        output_line++;
        free($1);
        free($3);
    }
    | ID '=' expr {
        printf("%d %s = %s\n", output_line, $1, $3);
        output_line++;
        free($1);
        free($3);
    }
    ;

expr:
    expr '+' term {
        char* temp = new_temp();
        printf("%d %s = %s + %s\n", output_line, temp, $1, $3);
        output_line++;
        $$ = temp;
        free($1);
        free($3);
    }
    | expr '-' term {
        char* temp = new_temp();
        printf("%d %s = %s - %s\n", output_line, temp, $1, $3);
        output_line++;
        $$ = temp;
        free($1);
        free($3);
    }
    | term {
        $$ = $1;
    }
    ;

term:
    term '*' factor {
        char* temp = new_temp();
        printf("%d %s = %s * %s\n", output_line, temp, $1, $3);
        output_line++;
        $$ = temp;
        free($1);
        free($3);
    }
    | term '/' factor {
        char* temp = new_temp();
        printf("%d %s = %s / %s\n", output_line, temp, $1, $3);
        output_line++;
        $$ = temp;
        free($1);
        free($3);
    }
    | term '%' factor {
        char* temp = new_temp();
        printf("%d %s = %s %% %s\n", output_line, temp, $1, $3);
        output_line++;
        $$ = temp;
        free($1);
        free($3);
    }
    | factor {
        $$ = $1;
    }
    ;

factor:
    func_call {
        $$ = $1;
    }
    | '(' expr ')' {
        $$ = $2;
    }
    | ID {
        $$ = strdup($1);
        free($1);
    }
    | NUM {
        $$ = strdup($1);
        free($1);
    }
    | '-' factor %prec UMINUS {
        char* temp = new_temp();
        printf("%d %s = -%s\n", output_line, temp, $2);
        output_line++;
        $$ = temp;
        free($2);
    }
    ;

func_call:
    SQRT '(' expr ')' {
        char* temp = new_temp();
        printf("%d %s = sqrt(%s)\n", output_line, temp, $3);
        output_line++;
        $$ = temp;
        free($3);
    }
    | POW '(' expr ',' expr ')' {
        char* temp = new_temp();
        printf("%d %s = pow(%s, %s)\n", output_line, temp, $3, $5);
        output_line++;
        $$ = temp;
        free($3);
        free($5);
    }
    | LOG '(' expr ')' {
        char* temp = new_temp();
        printf("%d %s = log(%s)\n", output_line, temp, $3);
        output_line++;
        $$ = temp;
        free($3);
    }
    | EXP '(' expr ')' {
        char* temp = new_temp();
        printf("%d %s = exp(%s)\n", output_line, temp, $3);
        output_line++;
        $$ = temp;
        free($3);
    }
    | SIN '(' expr ')' {
        char* temp = new_temp();
        printf("%d %s = sin(%s)\n", output_line, temp, $3);
        output_line++;
        $$ = temp;
        free($3);
    }
    | COS '(' expr ')' {
        char* temp = new_temp();
        printf("%d %s = cos(%s)\n", output_line, temp, $3);
        output_line++;
        $$ = temp;
        free($3);
    }
    | TAN '(' expr ')' {
        char* temp = new_temp();
        printf("%d %s = tan(%s)\n", output_line, temp, $3);
        output_line++;
        $$ = temp;
        free($3);
    }
    | ABS '(' expr ')' {
        char* temp = new_temp();
        printf("%d %s = abs(%s)\n", output_line, temp, $3);
        output_line++;
        $$ = temp;
        free($3);
    }
    ;

%%

void yyerror(const char* s) {
    
}

char* new_temp() {
    char* temp = (char*)malloc(20);
    sprintf(temp, "t%d", ++temp_counter);
    return temp;
}

int main(int argc, char* argv[]) {
    yyin = fopen("input.txt", "r");
    if (!yyin) {
        return 1;
    }
    
    temp_counter = 0;
    output_line = 1;
    
    yyparse();
    
    fclose(yyin);
    return 0;
}