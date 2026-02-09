%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex();

FILE *tac_file;
FILE *asm_file;

int t_count = 1;
int tac_line = 1;
int asm_line = 1;

char* get_temp() {
    char* buf = malloc(10);
    sprintf(buf, "t%d", t_count++);
    return buf;
}
%}

%union {
    char* str;
}

%token <str> ID NUM
%token SQRT POW LOG EXP SIN COS TAN ABS NEWLINE
%type <str> Expression Term Factor FunctionCall

%%

Program: StatementList ;

StatementList: Statement 
             | StatementList NEWLINE Statement 
             ;

Statement: ID '=' Expression {
                fprintf(tac_file, "%d %s = %s\n", tac_line++, $1, $3);
                fprintf(asm_file, "%d MOV %s , R0\n\n", asm_line++, $1);
             }
         | /* empty */
         ;

Expression: Expression '+' Term {
                char* t = get_temp();
                fprintf(tac_file, "%d %s = %s + %s\n", tac_line++, t, $1, $3);
                fprintf(asm_file, "%d ADD R0 , R1\n", asm_line++);
                $$ = t;
             }
           | Expression '-' Term {
                char* t = get_temp();
                fprintf(tac_file, "%d %s = %s - %s\n", tac_line++, t, $1, $3);
                fprintf(asm_file, "%d SUB R0 , R1\n", asm_line++);
                $$ = t;
             }
           | Term { $$ = $1; }
           ;

Term: Term '*' Factor {
        char* t = get_temp();
        fprintf(tac_file, "%d %s = %s * %s\n", tac_line++, t, $1, $3);
        fprintf(asm_file, "%d MUL R0 , R1\n", asm_line++);
        $$ = t;
    }
    | Term '/' Factor {
        char* t = get_temp();
        fprintf(tac_file, "%d %s = %s / %s\n", tac_line++, t, $1, $3);
        fprintf(asm_file, "%d DIV R0 , R1\n", asm_line++);
        $$ = t;
    }
    | Factor { $$ = $1; }
    ;

Factor: FunctionCall { $$ = $1; }
      | '(' Expression ')' { $$ = $2; }
      | ID { 
          fprintf(asm_file, "%d MOV R%d , %s\n", asm_line++, (t_count % 2), $1);
          $$ = $1; 
        }
      | NUM { 
          fprintf(asm_file, "%d MOV R%d , #%s\n", asm_line++, (t_count % 2), $1);
          $$ = $1; 
        }
      | '-' Factor {
          char* t = get_temp();
          fprintf(tac_file, "%d %s = -%s\n", tac_line++, t, $2);
          fprintf(asm_file, "%d NEG R0\n", asm_line++);
          $$ = t;
        }
      ;

FunctionCall: SQRT '(' Expression ')' {
                char* t = get_temp();
                fprintf(tac_file, "%d %s = sqrt ( %s )\n", tac_line++, t, $3);
                fprintf(asm_file, "%d SQRT R0\n", asm_line++);
                $$ = t;
            }
            | POW '(' Expression ',' Expression ')' {
                char* t = get_temp();
                fprintf(tac_file, "%d %s = pow ( %s , %s )\n", tac_line++, t, $3, $5);
                fprintf(asm_file, "%d POW R0 , R1\n", asm_line++);
                $$ = t;
            }
            | LOG '(' Expression ')' {
                char* t = get_temp();
                fprintf(tac_file, "%d %s = log ( %s )\n", tac_line++, t, $3);
                fprintf(asm_file, "%d LOG R0\n", asm_line++);
                $$ = t;
            }
            | EXP '(' Expression ')' {
                char* t = get_temp();
                fprintf(tac_file, "%d %s = exp ( %s )\n", tac_line++, t, $3);
                fprintf(asm_file, "%d EXP R0\n", asm_line++);
                $$ = t;
            }
            | SIN '(' Expression ')' {
                char* t = get_temp();
                fprintf(tac_file, "%d %s = sin ( %s )\n", tac_line++, t, $3);
                fprintf(asm_file, "%d SIN R0\n", asm_line++);
                $$ = t;
            }
            | COS '(' Expression ')' {
                char* t = get_temp();
                fprintf(tac_file, "%d %s = cos ( %s )\n", tac_line++, t, $3);
                fprintf(asm_file, "%d COS R0\n", asm_line++);
                $$ = t;
            }
            | TAN '(' Expression ')' {
                char* t = get_temp();
                fprintf(tac_file, "%d %s = tan ( %s )\n", tac_line++, t, $3);
                fprintf(asm_file, "%d TAN R0\n", asm_line++);
                $$ = t;
            }
            | ABS '(' Expression ')' {
                char* t = get_temp();
                fprintf(tac_file, "%d %s = abs ( %s )\n", tac_line++, t, $3);
                fprintf(asm_file, "%d ABS R0\n", asm_line++);
                $$ = t;
            }
            ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Parsing Error: %s\n", s);
}

int main() {
    extern FILE *yyin;
    yyin = fopen("lab6task2.txt", "r");
    if(!yyin) {
        printf("Error: Could not open lab6task2.txt\n");
        return 1;
    }

    tac_file = fopen("tac.txt", "w");
    asm_file = fopen("asm.txt", "w");

    if(!tac_file || !asm_file) {
        printf("Error opening output files.\n");
        return 1;
    }

    yyparse();

    fclose(yyin);
    fclose(tac_file);
    fclose(asm_file);
    
    printf("Compilation successful. Check tac.txt and asm.txt\n");
    return 0;
}