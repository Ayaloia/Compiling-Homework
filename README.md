# CMINUS 语言的词法分析和语法分析
## 编译原理课程设计
***

## 实现功能

1. 实现了对于十六进制、八进制数的识别，并且可以检测错误输入的十/十六/八进制数字。

    十六进制和八进制的数值开头是有明显标识的，分别为 `0x` 和 `0`，可以编写一个识别这两个标识再识别相关标识的正则。

    至于错误输入检测，考虑这样一个在 C 语言中的基本规定，即标识符是不能以数字开头的。那么我们可以简单一律认为以数字开头的一组字符表示的就是数字，读取后再去判断其是否是符合规范的数字。

    这样的好处在于能够把输入的这组字符全部读取完，并且防止额外词义的产生。比如说 `== 1561abc151 ==`，中间的这组 `1561abc151` 如果不谨慎处理很有可能会得到 `INT ID INT` 的结果。但我们往往期望是这组字符应该只代表一个词义，在这里应该是 `INT`。

2. 实现了注释

    注释有两种，一种是 `//` 的形式对该行之后的所有文字全部忽略；一种是以 `/*` 起始，直到遇到第一个 `*/` 前，所有的文字全部忽略。主要难点是后者，写一般的正则要识别这种注释是很难的，还好的是 Flex 不是只有正则。

    这里有一种可以理解为语境的功能，在定义部分通过 `%x ABC` 声明，在识别正则成功后的 Action 内通过 `BEGIN(ABC);` 激活。可以理解为是切换到了另一组匹配规则，通过 `<ABC>xxx` 即可编写在该语境下的匹配规则，通过 `BEGIN(INITIAL);` 可切换回默认的语境。

    因此实现就变得比较简单了，只要在碰到 `/*` 时切换到另一个语境，匹配其中的任何文字但不做任何事，直到碰到 `*/` 并切换回原语境。

3. 构建语法树并输出

    节点的属性如下：

    ```c++
    struct node {
        nodeType type;
        const char *word;
        int line;
        nodeVal val;
        vector<node *> sons;
    };
    ```

    其中 `nodeType` 主要用于识别语义节点以及词义节点中有特殊输出的节点，用于输出的特殊要求的处理；`word` 为该节点的作为终结符或非终结符时的名称。`line` 为行号，`val` 为一个 union 类型，主要储存的是题目对一些特别的词法单元要求的额外输出的值。`sons` 是储存的是子节点们的指针。

    词法单元的构建是在 Flex 中实现的，语法单元的构建是在 Bison 中实现的，使用的都是 `node*` 类型。Flex 构建的都是叶节点，在 Bison 自下而上构建父节点，并将叶节点连接到父节点上。对于由空字符串归约出的非终结符，不构建节点，赋值指针为 `nullptr`。

    输出的时候从根节点开始进行 DFS，按要求进行前序遍历并输出即可，需要注意对于空指针的识别。

4. 行号的准确识别

    众所周知 Flex 提供了 `yylineno` 表示当前识别到的行号，在定义部分通过 `%option yylineno` 即可启用。但在和 Bison 联用的时候，这个行号有时候是会不准的，一个原因是 Bison 使用的是 LALR(1) 文法，会看当前词语后面的词语以确定具体动作，这样就可能导致创建语义节点的时候当前的行号不正确的问题。

    这个问题解决的主要方法一个是自己新建一个变量，仅在识别到换行符 `\n` 的时候对该变量加一，这样行号相对来说更加可控。另一个更关键的方法是在自上而下构建语法树的时候，把父节点的行号设置为在自己和子节点们之间的最小的行号。因为父节点是由子节点归约来的，考虑到作为叶节点的词法单元的行数是一定正确的，通过归纳证明可以得出通过这种方法所有节点得到的行数一定是符合期望的。

    因此只需要在构建父节点之后执行一次更新行数的操作即可。不过很多这种相关操作还有编写上的麻烦，比如这个就需要在几乎每个归约后的动作中都添加一条语句，一个个复制黏贴是非常繁琐的。这里添加时使用的是正则替换的方法，搜索：
    ```re
    sons.emplace_back\(\$(\d)\);\n    \}
    ```
    该正则，识别的是每个动作的最后一行，并使用：
    ```re
    sons.emplace_back($$$1);\n        updateNodeLine($$$$)\n    }
    ```
    进行替换，可以在每个需要的动作最后再加上更新行数的操作，可以说省事省力省心。

5. 实现了多个语法错误识别

    主要使用了错误恢复的特性，这个主要用于对于一些可预见匹配的错误恢复，比如大中小括号以及句尾的分号等。比如对于 `a[1,4,50,5,-3]`，可以避免识别到 `,` 报错后又分析到其后的词语再次报错的情况，使用 `error RB` 可以使得报错后忽略之后的所有词语直到遇到 RB（即右中括号）。

    考虑过程中也是发现了很多语法错误是很难准确判断识别原因的，从错误中恢复更是难上加难。就比如说 `int a; b, c;`，语法分析会认为错误点是在 `b, c;`，但往往更可能是 `a` 后面的分号打错了；只有一个左大括号但是没有相应匹配的右大括号的情景，甚至都不好形容错误行号。只能说确实理解到为什么有时候编译器的报错千奇百怪了。

6. 实现了对包括指数形式在内的浮点数的识别

    经测试发现形如 `.514` `1969.` `1.1` 的浮点数字面量的表示在 C++ 语言中都是合法的，因此这里也都将这些作为正确识别并进行处理。

    对于指数形式，主要是额外编写一个正则识别即可。

## 编译方法

本人在 Arch Linux 下,使用 flex 2.6.4, bison 3.8.2, Make 4.4.1, gcc/g++ 14.1.1 并且使用 C++11 标准编译成功。
因为编写的是 C++ 代码，因此使用 g++ 进行编译。

进入当前文件夹后输入 `make` 即可开始编译，编译完成后输入 `./cminus <filename>` 即可运行，分析结果会输出至控制台。输入 `make clean` 可清除所有编译产物。

也提供了编译后的程序，可使用 `chmod +x ./cminus` 添加权限后运行。
