%{
    #include "AST.h"
    yyerror(const char *s);  
    extern int yylex(void);
%}

%union { AST* val; int type; }

%token	CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO 
%token  CONTINUE BREAK RETURN SIZEOF

%token	INT_CONST FLOAT_CONST IDENTIFIER STRING 

%token  ADD SUB MUL DIV BIT_XOR LPAREN RPAREN SEMICOLON ELLIPSIS
%token	SHIFT_RIGHT SHIFT_LEFT INC DEC PTR AND OR LE GE EQ NE
%token  LBRACE RBRACE COMMA COLON ASSIGN LBRACKET RBRACKET DOT
%token  BIT_AND NOT NEGATION MOD LT GT BIT_OR QM
%token  SHIFT_LEFT_ASSIGN SHIFT_RIGHT_ASSIGN AND_ASSIGN 
%token  MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN SUB_ASSIGN
%token	XOR_ASSIGN OR_ASSIGN

%token	TYPEDEF EXTERN STATIC AUTO REGISTER INLINE
%token	CONST RESTRICT VOLATILE
%token	BOOL CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE VOID
%token	STRUCT UNION ENUM

%type <val> IDENTIFIER FLOAT_CONST INT_CONST STRING
%type <type> INT FLOAT DOUBLE CHAR

%left COMMA
%right ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN SUB_ASSIGN SHIFT_LEFT_ASSIGN SHIFT_RIGHT_ASSIGN AND_ASSIGN 
%left OR
%left AND
%left BIT_OR
%left BIT_XOR
%left BIT_AND
%left EQ NE
%left LT GT LE GE
%left SHIFT_RIGHT SHIFT_LEFT
%left ADD SUB 
%left MUL DIV
%right NOT NEGATION
%left LPAREN RPAREN LBRACE RBRACE LBRACKET RBRACKET DOT PTR

%start translation_unit

%%  

constant
    : FLOAT_CONST  { printf("%s", $1->text); }
    | INT_CONST { printf("%s", $1->text); }
    ;

// external definitions

translation_unit
    : external_declaration
    | translation_unit external_declaration
    ;

external_declaration
	: function_definition
	| declaration
    ;

function_definition
    : declaration_specifiers declarator compound_statement
    | declaration_specifiers declarator declaration_list compound_statement
    ; 

declaration_list
    : declaration
    | declaration_list declaration
    ;

// declarations

declaration
	: declaration_specifiers SEMICOLON
	| declaration_specifiers init_declarator_list SEMICOLON 
    ;

declaration_specifiers
    : type_specifier
    | type_specifier declaration_specifiers
    | function_specifier
    | function_specifier declaration_specifiers
    | storage_class_specifier
	| storage_class_specifier declaration_specifiers
    | type_qualifier
    | type_qualifier declaration_specifiers
    ;

init_declarator_list
    : init_declarator
    | init_declarator_list COMMA init_declarator
    ;

init_declarator
    : declarator
    | declarator ASSIGN initializer
    ;

storage_class_specifier
    : TYPEDEF
    | EXTERN
    | STATIC
    | AUTO
    | REGISTER
    ;

type_specifier 
    : VOID
    | INT { printf("%d", $1); }
    | FLOAT { printf("%d", $1); }
    | DOUBLE { printf("%d", $1); }
    | CHAR { printf("%d", $1); }
    | LONG
    | SHORT
    | SIGNED
    | UNSIGNED
    | BOOL
    | struct_or_union_specifier
    | enum_specifier
    ;

struct_or_union_specifier
    : struct_or_union IDENTIFIER LBRACE struct_declaration_list RBRACE
    | struct_or_union LBRACE struct_declaration_list RBRACE
    | struct_or_union IDENTIFIER
    ;

struct_or_union
    : STRUCT
    | UNION
    ;

struct_declaration_list
    : struct_declaration
    | struct_declaration_list struct_declaration
    ;

struct_declaration
    : specifier_qualifier_list struct_declarator_list SEMICOLON

specifier_qualifier_list
    : type_specifier specifier_qualifier_list
    | type_specifier
    | type_qualifier specifier_qualifier_list
    | type_qualifier
    ;

struct_declarator_list
    : struct_declarator
    | struct_declarator_list COMMA struct_declarator
    ;

struct_declarator
    : declarator
    | declarator COLON constant_expression
    | COLON constant_expression
    ;

enum_specifier
    : ENUM IDENTIFIER LBRACE enumerator_list RBRACE
    | ENUM LBRACE enumerator_list RBRACE
    | ENUM IDENTIFIER LBRACE enumerator_list COMMA RBRACE
    | ENUM LBRACE enumerator_list COMMA RBRACE
    | ENUM IDENTIFIER
    ; 

enumerator_list
    : enumerator
    | enumerator_list COMMA enumerator
    ;

enumerator
    : IDENTIFIER
    | IDENTIFIER ASSIGN constant_expression
    ;

type_qualifier
	: CONST
	| RESTRICT
	| VOLATILE
	;

function_specifier
    : INLINE
    ;

declarator
    : direct_declarator
    | pointer direct_declarator
    ;

direct_declarator
    : IDENTIFIER
    | LPAREN declarator RPAREN
    | direct_declarator LBRACKET type_qualifier_list assignment_expression RBRACKET
    | direct_declarator LBRACKET type_qualifier_list RBRACKET
    | direct_declarator LBRACKET STATIC type_qualifier_list assignment_expression RBRACKET
    | direct_declarator LBRACKET STATIC assignment_expression RBRACKET
    | direct_declarator LBRACKET type_qualifier_list STATIC assignment_expression RBRACKET
    | direct_declarator LBRACKET type_qualifier_list MUL RBRACKET
    | direct_declarator LBRACKET MUL RBRACKET
    | direct_declarator LPAREN parameter_type_list RPAREN
    | direct_declarator LPAREN  identifier_list RPAREN
    ;   

pointer
    : MUL
    | MUL pointer
    ;

type_qualifier_list
	: type_qualifier
	| type_qualifier_list type_qualifier
	;

parameter_type_list
	: parameter_list COMMA ELLIPSIS
	| parameter_list
	;
    
parameter_list
    : parameter_declaration
    | parameter_list COMMA parameter_declaration
    ;

parameter_declaration
    : declaration_specifiers  declarator
    | declaration_specifiers abstract_declarator
    | declaration_specifiers
    ;

identifier_list
    : IDENTIFIER
    | identifier_list COMMA IDENTIFIER
    ;

type_name
	: specifier_qualifier_list abstract_declarator
    | specifier_qualifier_list
	;

abstract_declarator
	: pointer direct_abstract_declarator
    | direct_abstract_declarator
	| pointer
	;

direct_abstract_declarator
	: LPAREN abstract_declarator RPAREN
    | direct_abstract_declarator LBRACKET assignment_expression RBRACKET
    | direct_abstract_declarator LBRACKET RBRACKET
    | direct_abstract_declarator LBRACKET MUL RBRACKET
	| direct_abstract_declarator LPAREN parameter_type_list RPAREN
    | direct_abstract_declarator LPAREN RPAREN
	;

initializer
    : assignment_expression
    | LBRACE initializer_list RBRACE
    | LBRACE initializer_list COMMA RBRACE
    ;

initializer_list
    : designation initializer
    | initializer
    | initializer_list COMMA designation initializer
    | initializer_list COMMA initializer
    ;

designation
    : designator_list ASSIGN
    ;

designator_list
    : designator
    | declaration_list designator
    ;

designator
    : LBRACKET constant_expression RBRACKET
    | DOT IDENTIFIER
    ;

// expressions

primary_expression
    : IDENTIFIER
    | constant
    | STRING
    | LPAREN expression RPAREN
    ;

postfix_expression
    : primary_expression
    | postfix_expression LBRACKET expression RBRACKET
    | postfix_expression LPAREN RPAREN
    | postfix_expression LPAREN argument_expression_list RPAREN
    | postfix_expression DOT IDENTIFIER
    | postfix_expression PTR IDENTIFIER
    | postfix_expression INC
    | postfix_expression DEC
    | LPAREN type_name RPAREN LBRACE initializer_list RBRACE
	| LPAREN type_name RPAREN LBRACE initializer_list COMMA RBRACE
    ;

argument_expression_list
    : assignment_expression
    | argument_expression_list COMMA assignment_expression
    ;

unary_expression
    : postfix_expression
    | INC unary_expression
    | DEC unary_expression
    | unary_operator cast_expression
    | SIZEOF unary_expression
    | SIZEOF LPAREN type_name RPAREN
    ;

unary_operator
    : BIT_AND
    | MUL
    | ADD
    | SUB
    | NEGATION
    | NOT
    ;

cast_expression
    : unary_expression
    | LPAREN type_name RPAREN cast_expression
    ;

multiplicative_expression
    : cast_expression
    | multiplicative_expression MUL cast_expression
    | multiplicative_expression DIV cast_expression
    | multiplicative_expression MOD cast_expression
    ;

additive_expression
    : multiplicative_expression
    | additive_expression ADD multiplicative_expression
    | additive_expression SUB multiplicative_expression
    ;

shift_expression
    : additive_expression
    | shift_expression SHIFT_LEFT additive_expression
    | shift_expression SHIFT_RIGHT additive_expression
    ;

relational_expression
    : shift_expression
    | relational_expression LT shift_expression
    | relational_expression GT shift_expression
    | relational_expression LE shift_expression
    | relational_expression GE shift_expression
    ;

equality_expression
    : relational_expression
    | equality_expression EQ relational_expression
    | equality_expression NE relational_expression
    ;

and_expression
    : equality_expression
    | and_expression BIT_AND equality_expression
    ;
 
exclusive_or_expression
    : and_expression
    | exclusive_or_expression BIT_XOR and_expression
    ;

inclusive_or_expression
    : exclusive_or_expression
    | inclusive_or_expression BIT_OR exclusive_or_expression
    ;

logical_and_expression
    : inclusive_or_expression
    | logical_and_expression AND inclusive_or_expression
    ;

logical_or_expression
    : logical_and_expression
    | logical_or_expression OR logical_and_expression
    ;

conditional_expression
    : logical_or_expression
    | logical_or_expression QM expression COLON conditional_expression
    ;

assignment_expression
    : conditional_expression
    | unary_expression assignment_operator assignment_expression
    ;

assignment_operator
    : ASSIGN
    | MUL_ASSIGN
    | DIV_ASSIGN
    | MOD_ASSIGN
    | ADD_ASSIGN
    | SUB_ASSIGN
    | SHIFT_LEFT_ASSIGN
    | SHIFT_RIGHT_ASSIGN
    | AND_ASSIGN
    | XOR_ASSIGN
    | OR_ASSIGN
    ;

expression
    : assignment_expression
    | expression COMMA assignment_expression
    ;

constant_expression
    : conditional_expression
    ;

// statements

statement
    : compound_statement
    | expression_statement
    | selection_statement
    | iteration_statement
    | jump_statement
    | labeled_statement
    ;   

labeled_statement
    : IDENTIFIER COLON statement
    | CASE constant_expression COLON statement
    | DEFAULT COLON statement
    ;

compound_statement
    : LBRACE RBRACE
    | LBRACE block_item_list RBRACE
    ;

block_item_list
    : block_item
    | block_item_list block_item
    ;

block_item
    : declaration
    | statement
    ;

expression_statement
    : expression SEMICOLON
    | SEMICOLON
    ;
 
selection_statement
    : IF LPAREN expression RPAREN statement
    | IF LPAREN expression RPAREN statement ELSE statement
    | SWITCH LPAREN expression RPAREN statement
    ;

iteration_statement
    : WHILE LPAREN expression RPAREN statement
    | DO statement WHILE LPAREN expression RPAREN
    | FOR LPAREN expression_statement expression_statement RPAREN statement
    | FOR LPAREN expression_statement expression_statement expression RPAREN statement
    ;

jump_statement
    : CONTINUE SEMICOLON
    | BREAK SEMICOLON
    | RETURN SEMICOLON
    | RETURN expression SEMICOLON
    | GOTO IDENTIFIER SEMICOLON
    ;


%%

int main(int argc, char *argv[])
{
    extern FILE *yyin, *yyout;
    char output[256];
    yyin = fopen(argv[1], "r");
    sscanf(argv[1], "%s", output);
    strcat(output, ".out");
    yyout = fopen(output, "w");
    yyparse();
    fclose(yyin);
    fclose(yyout);
    return 0;
}

yyerror(const char *s)
{
    // fflush(stdout);
	// fprintf(stderr, "\033[1m\033[31m");
	// fprintf(stderr, "*** %d: %s near '%s'\n", yylineno, s, yytext);
	// fprintf(stderr, "\033[0m");
}