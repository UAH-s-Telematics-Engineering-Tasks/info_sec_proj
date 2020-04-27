# Demostración práctica: Troyanos
Aun siendo este trabajo eminentemente práctico hemos querido preparar una demostración práctica que sustente lo ya expuesto. Ya que los términos en los que hemos discutido los conceptos anteriores han sido de carácter general hemos optado por hacer lo mismo en esta demostración. Esto es, en vez de buscar un ataque tremendamente específico hemos escogido uno sencillo que nos permita analizar la base teórica de la que hacen uso de una manera clara y concisa.

Con el objetivo de arrojar incluso más luz sobre el malware oculto en general y los troyanos en particular decidimos incluso preparar nuestra propia versión con el objetivo de asentar los conocimientos adquiridos a la vez que relacionábamos el contenido de esta asignatura con el de otras impartidas en el grado.

Creemos que con lo anterior hemos logrado demostrar las características básicas de este tipo de ataques que suelen ser, además, el primer paso en una cadena mucho más compleja.

## Trabajando con Kali
Nuestro objetivo con esta sección no es solo analizar el funcionamiento de los troyanos sino también brindar una pequeña "guía" que permita a cualquiera recrear nuestras pruebas. Es por ello que es necesario describir el sistema con el que se ha generado todo.

Dadas las facilidades que nos ofrece hemos escogido Kali Linux para generar los payloads (más sobre ellos a continuación) y controlar las máquinas comprometidas. Kali es una distribución que usa Linux como kernel y que se basa en el archiconocida Debian. Sobre esta base robusta se ha instalado una gran cantidad de herramientas comunmente empleadas en muchas áreas de la ciberseguridad como puede sern la ingeniería social, la ruptura de contraseñas, auditoría de redes WiFi... En nuestro caso estamos interesados en Metasploit y sus programas relacionados. Metasploit es un framework que nos permite generar ataques contra vulnerabilidades conocidas de una manera clar y rápida. Dado el soporte que ofrece la firma Rapid7, afincada en Boston, nuevas vulnerabilidades y los ataques que las aprovechan se añaden de manera continua. En definitiva, es una herramienta que permite preparar ataques de una manera rápida y que además ofrece una forma clara de continuar con la post-explotación una vez hemos conseguido acceder a la máquina víctima.

Si bien Metasploit es una herramienta tremendamente potente nosotros solo hemos arañado la superficie de la funcionalidad que nos ofrece. En nuestro caso haremos uso del intérprete de órdenes msfconsole y del generador de payloads msfvenom. Ambas herramientas se encuentran instaladas por defecto con lo que no nos las tendremos que ver con la compilación de una suite de herramientas tan extensa...

## Terminología y fases del ataque
Tras haberlo mencionado varias veces creemos que es el momento de esclarecer el significado del payload. El término payload es un anglicismo al que en español nos solemos referir como carga útil en el contexto de las redes que es en el que nos hemos formado. En este ámbito el payload es código que, de ser ejecutado, nos brinda acceso al sistema objetivo. Quizá lo más importante de esta última oración es la palabra "ejecutado". Si bien el payload es el paso anterior a conseguir el acceso que buscamos no vale de nada que esté almacenado en disco; necesitamos que de alguna manera se ejecute.

Para lograr esta ejecución de código arbitraria tenemos que sacar partido a alguna vulnerabilidad. Estas vulnerabilidades son errores en programas o interacciones entre partes del sistema que pueden ser aprovechadas para llevar a cabo acciones a priori no permitidas. La vulnerabilidad por si sola no implica nada, simplemente está ahí, esperando a ser arreglada mediante una actualización. Los atacantes sin embargo intentarán aprovecharla para lograr sus objetivos. En nuestro caso, la ejecución del payload que hemos preparado.

La forma de aprovechar la vulnerabilidad es a través de un exploit. Este exploit suele ser un programa que toma acciones para intentar aprovechar una vulnerabilidad determinada. Teniendo en cuenta la relación entre vulnerabilidades y exploits aprovechamos para señalar por qué es tan importante trabajar con equipos actualizados. Además de funcionalidades nuevas las actualizaciones se encargan de "parchear" vulnerabilidades que se han encontrado para evitar que puedan ser aprovechadas...

En nuestro caso estamos interesados en analizar lo que ocurre una vez se ejecuta el payload, no en la forma de lograrlo. Si aplicamos estos conceptos a raja tabla, en nuestro caso el exploit es el usuario, es quien va a ejecutar el programa que nos dará acceso a su sistema. Una vez analizado el funcionamiento de nuestro troyano entraremos a explicar una forma en la que podemos explotar el lector de PDFs Adobe Acrobat Reader para que no dependamos de el usuario. Creemos que al posponer esta explicación conseguiremos centrar la atención en el malware propiamente dicho mientras que, dada la independencia entre las fases del ataque, no dificultamos seguir esta demostración.

De la discusión anterior se desgrana el proceso común de ataque a un sistema víctima:

- Generar el payload que deseamos ejecutar en la víctima
- Encontrar una vulnerabilidad que podamos aprovechar
- Ejecutar el exploit que saque partido a esa vulnerabilidad para lograr ejecutar el payload
- Ejecutar el payload generado en la víctima para conseguir, en nuestro caso, acceso al sistema
- Emplear el acceso al sistema para lo que se desee: escalada de privilegios, conseguir información...

Con este esquema claro pasamos a detallar cada una de las partes.

## Generando el payload: MSFVENOM
