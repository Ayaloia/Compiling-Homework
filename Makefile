main: lex.yy.c cMinus.tab.c cMinusMain.cpp
	g++ lex.yy.c cMinus.tab.c cMinusMain.cpp -I. -g -o cminus

lex.yy.c: cMinus.l cMinus.tab.c
	flex cMinus.l

cMinus.tab.c: cMinus.y
	bison -d cMinus.y

clean:
	rm lex.yy.c cMinus.tab.c cMinus.tab.h cminus
