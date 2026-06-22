---------------------------------------------------------------------------
---Widget para Goosky S2 y Radiomaster TX16S mk2
-- Versión de Roberto Domingues
-- EdgeTX 2.11+

-- La imagen "S2t.png" debe estar en la carpeta IMAGES del widget para que
-- se muestre correctamente.
---------------------------------------------------------------------------
---
---@diagnostic disable: undefined-global
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- variables globales
----------------------------------------------------------------------------
-- Esta sección define las variables globales que se utilizan en el widget.
-- Estas variables pueden almacenar información sobre el estado del widget,
-- como el tiempo de inicio, el tiempo transcurrido, si el temporizador está
-- en funcionamiento, etc. En este caso, se definen variables para controlar
-- un temporizador interno del widget y una variable para el color rosa (ROSA)
-- que se utiliza en la función de refresco para mostrar información en rosa
-- cuando el valor de RSSI es diferente de 0.
---------------------------------------------------------------------------

local ROSA = lcd.RGB(206, 126, 252)

-- Variables internas del timer
local startTime = 0
local elapsed = 0
local running = false

---------------------------------------------------------------------------
--- Funciones auxiliares
---------------------------------------------------------------------------
--- Estas funciones se utilizan para realizar tareas
---  específicas que se necesitan en el widget, como cargar imágenes,
---  dibujar iconos personalizados, formatear texto, etc. Estas funciones
---  ayudan a mantener el código organizado y modular, permitiendo que la
---  lógica principal del widget sea más clara y fácil de entender. En este
---  caso, se definen funciones para cargar imágenes desde la carpeta IMAGES
---  del widget, formatear etiquetas de fuentes de datos y dibujar un icono
---  de batería personalizado. Estas funciones se pueden llamar desde la
---  función de refresco para mostrar información visualmente atractiva y
---  personalizada en la pantalla del widget, mejorando la experiencia del
---  usuario y proporcionando información relevante de manera clara y concisa.
---------------------------------------------------------------------------

-- dibujar un icono de batería personalizado en la pantalla del widget,
-- utilizando las coordenadas (x, y), las dimensiones (w, h), el porcentaje de
-- batería (percent) y el color (color) como parámetros. El icono de batería
-- se dibuja como un rectángulo con un pequeño rectángulo adicional para
-- representar el terminal positivo de la batería. El nivel de carga de la
-- batería se muestra como un rectángulo lleno dentro del icono, cuyo ancho
-- se ajusta según el porcentaje de batería. El color del rectángulo lleno
-- varía según el nivel de carga, proporcionando una representación visual
-- clara del estado de la batería.

local function drawBatteryIcon(x, y, w, h, percent, color)
    lcd.drawRectangle(x, y, w, h, WHITE)
    lcd.drawFilledRectangle(x + w, y + h / 3, 4, h / 3, WHITE)
    lcd.drawFilledRectangle(x + 1, y + 1, (w - 2) * percent, h - 2, color)
end

--*************************************************************************

--- CAMPOS DEL WIDGET
--- Cada widget debe definir al menos tres campos: NAME, CREATE, REFRESH y RETURN.
--- El campo NAME es una cadena que identifica el widget, CREATE es una función
---  que se llama para crear una instancia del widget, REFRESH es una
---  función que se llama para dibujar el widget en la pantalla, y RETURN es una
---  función que se llama para devolver el valor del widget.
---  Además, el widget puede definir un campo OPTIONS para permitir que
---  el usuario configure opciones personalizadas para el widget, y un campo
---  UPDATE para actualizar las opciones del widget cuando el usuario las
---  cambie en la interfaz de configuración. Estos campos son esenciales
---  para que el widget funcione correctamente en EdgeTX, y deben ser
---  definidos de manera clara y coherente para que el widget sea fácil de
---  usar y personalizar por los usuarios.

---------------------------------------------------------------------------
--- Primer campo obligatorio: NAME  (string)
---
--- La carpeta del widget debe tener el mismo nombre que el campo NAME para
--- que el widget se registre correctamente en EdgeTX. El campo NAME es una
--- cadena que identifica el widget.
---
-- Esta variable define el nombre del widget, que se mostrará en la interfaz
-- de configuración y en la lista de widgets disponibles. Es importante
-- elegir un nombre descriptivo y único para que los usuarios puedan
-- identificar fácilmente el widget y su función. El nombre también puede
-- ser utilizado en el código para referirse al widget, por lo que es
-- recomendable evitar caracteres especiales o espacios en blanco que puedan
-- causar problemas de sintaxis. En este caso, el widget se llama "gooskyS2",
-- lo que sugiere que está diseñado para mostrar información relacionada
-- con el helicóptero Goosky S2.
--
-- El nombre debe tener 10 caracteres o menos para que se muestre
-- correctamente en la interfaz de EdgeTX.
---------------------------------------------------------------------------
local name = "gooskyS2"

---------------------------------------------------------------------------
--- Segundo campo (opcional): OPTIONS (tabla)
---
-- Esta función define las opciones que el usuario puede configurar para el
-- widget. Cada opción tiene un nombre, un tipo
-- (SWITCH, RADIO, METER, PANEL, SOURCE, etc.)
-- y un valor por defecto. Estas opciones se mostrarán en la interfaz de
-- configuración del widget y el usuario podrá modificarlas según sus
-- necesidades. El widget luego puede acceder a estas opciones para mostrar
-- la información correspondiente.
-- El número máximo de opciones es 10

--[[
Tipos de opciones:
- COLOR:        Displays a color picker, returns a color flag value

- BOOL:         Displays a toggle/checkbox, value toggles between 0 and 1

- STRING:       Text input option, limited to  12 characters in 2.11.

- TIMER:        Choice option, lets you pick from available timers

- SOURCE:       Choice option, lets you pick from available sources
                (i.e. sticks, switches, LS)

- SWITCH:       Choice option to select from available switches.

- VALUE:        Numerical input option, can specify default, min and max value

- TEXT_SIZE:    Choice option, lets you pick from the available text sizes
                (i.e. small, large)

- ALIGNMENT:    Choice option, lets you pick from available alignment options
                (i.e. left, center, right)

- SLIDER:       Select numerical value using a slider control (available in 2.11)

- CHOICE:       Select numerical value using a custom popup list (available in 2.11)

- FILE:         Select a file from SD card / WIDGETS folder.
                Filename is limited to 12 characters maximum.

--]]
---------------------------------------------------------------------------


-- Esta tabla define las opciones configurables para el widget. Cada opción
--   tiene un nombre (en este caso, "Arm", "Motor", "Modo", "Revo"), un tipo
-- (en este caso, SOURCE, que permite seleccionar una fuente de datos como
-- un interruptor) y un valor por defecto (en este caso los interruptores, "SE", "SF", "SA", "SB").
-- Estas opciones se mostrarán en la interfaz de configuración del widget,
-- y el usuario podrá seleccionar las fuentes de datos correspondientes para
-- cada opción. El widget luego puede acceder a estas opciones para mostrar
-- la información relevante en la pantalla, como el estado de armado, el
-- estado del motor, el modo de vuelo, etc., según las fuentes de datos
-- seleccionadas por el usuario.
local options = {
    { "Arm",   SOURCE, "SE" },
    { "Motor", SOURCE, "SF" },
    { "Modo",  SOURCE, "SA" },
    { "Revo",  SOURCE, "SB" },
}


---------------------------------------------------------------------------
--- Tercer campo (obligatorio): CREATE (función)
---
--Esta función se llama una sola vez cuando se registra (se inicia) la
--instancia del widget. Aquí es donde se deben inicializar las variables,
--cargar recursos, cargar imágenes, etc. El widget se crea con una zona
--(zone) con las opciones (opts) que se definen en la tabla de opciones.
-- el parametro zone es un objeto que contiene las coordenadas y dimensiones
-- de la zona asignada al widget en la pantalla. El widget puede usar esta
-- información para dibujar su contenido dentro de esa zona específica.
-- El parámetro opts es una tabla que contiene las opciones configuradas
-- por el usuario para el widget, como los interruptores, fuentes de datos,
-- etc. Estas opciones se pueden usar para personalizar la apariencia y el
-- comportamiento del widget según las preferencias del usuario. En esta
-- función, también se puede cargar una imagen personalizada para el widget
-- utilizando la función Bitmap.open, lo que permite mostrar gráficos o iconos
-- específicos relacionados con el Goosky S2 o la Radiomaster TX16S mk2.
--
-- Parámetros:
-- - zone: un objeto que contiene las coordenadas (x, y) y
-- dimensiones (w, h) de la zona asignada al widget en la pantalla.
-- - opts: una tabla que contiene las opciones configuradas por el usuario
--  para el widget, como los interruptores, fuentes de datos, etc.
-- Estas opciones se pueden usar para personalizar la apariencia y el
-- comportamiento del widget según las preferencias del usuario.

-- Esta función debe devolver una tabla que representa el widget, que puede
-- contener cualquier información o estado necesario para el widget durante
-- su vida útil. Esta tabla se pasará a las funciones de actualización y
-- refresco ( update , background & refresh) para que puedan acceder a la
-- información del widget y mostrarla en la pantalla.
---------------------------------------------------------------------------

local function create(zone, opts)
    local widget = { zone = zone, options = opts or {} }

    -- Intento protegido de cargar la imagen seleccionada
    local ok, img = pcall(Bitmap.open, "/IMAGES/S2t.png")
    if ok and img then
        widget.bmp = img
    else
        widget.bmp = nil
    end

    return widget
end

---------------------------------------------------------------------------
--- Cuarto campo (opcional): UPDATE (función)
---
-- Esta función se llama cada vez que se modifican las opciones del widget
-- en la interfaz de configuración. Aquí es donde se deben actualizar las
-- opciones del widget con los nuevos valores configurados por el usuario.
-- El widget se actualiza con una tabla de opciones (opts) que contiene los
-- nuevos valores configurados por el usuario. Esta función es importante
-- para asegurarse de que el widget refleje correctamente las preferencias
-- del usuario y muestre la información correcta en la pantalla.
-- Al actualizar las opciones, el widget puede cambiar su apariencia,
-- mostrar diferentes datos o ajustar su comportamiento según las nuevas
-- configuraciones. Es importante que esta función sea eficiente y no cause
-- retrasos en la interfaz, ya que se llamará cada vez que el usuario
-- realice cambios en las opciones del widget.
-- Parámetros:
-- - widget: la tabla que representa el widget, que se creó en la función
-- create.
-- - opts: una tabla que contiene las nuevas opciones configuradas por el
-- usuario para el widget. Estas opciones pueden incluir interruptores,
-- fuentes de datos, etc., y se deben usar para actualizar la apariencia
-- y el comportamiento del widget según las preferencias del usuario.
---------------------------------------------------------------------------
local function update(widget, opts)
    widget.options = opts
end

---------------------------------------------------------------------------
--- Quinto campo (opcional): BACKGROUND (función)
---
--- EdgeTX llama a esta función para dibujar el fondo del widget. Aquí es
--- donde se deben implementar las funciones de dibujo para crear el fondo
--- del widget, como dibujar formas, líneas, colores, etc. El fondo se
--- dibuja antes de que se llame a la función de refresco, por lo que
--- cualquier elemento dibujado en esta función se mostrará detrás de los
--- elementos dibujados en la función de refresco. Es importante optimizar
--- esta función para que el fondo se dibuje de manera eficiente y no cause
--- retrasos en la interfaz. Además, el fondo debe ser lo suficientemente
--- claro para que los elementos dibujados en la función de refresco sean
--- legibles y visibles para el usuario.
--- Se ejecuta periódicamente solo cuando la instancia del widget no está
---  visible
-- Parámetros:
-- - widget: la tabla que representa el widget, que se creó en la función
-- create. Esta tabla puede contener cualquier información o estado necesario
-- para el widget durante su vida útil, y se puede usar para almacenar
-- datos que se necesiten para dibujar el fondo del widget.
---------------------------------------------------------------------------
--- En este caso, no se implementa una función de fondo personalizada, por
---  lo que el widget utilizará el fondo predeterminado de EdgeTX.
---  Si se desea agregar un fondo personalizado, se puede implementar esta
---  función para dibujar formas, líneas o colores específicos que
---  complementen la apariencia del widget y mejoren la legibilidad de la
---  información mostrada en la función de refresco.
--- Si no se necesita un fondo personalizado, esta función puede omitirse
---  o dejarse vacía, y el widget seguirá funcionando correctamente
---  utilizando el fondo predeterminado de EdgeTX.
--- Si se implementa una función de fondo personalizada, es importante
---  asegurarse de que el fondo no sea demasiado oscuro o demasiado claro,
---  para que los elementos dibujados en la función de refresco sean
---  legibles y visibles para el usuario. Además, se debe optimizar esta
---  función para que el fondo se dibuje de manera eficiente y no cause
---  retrasos en la interfaz.
----------------------------------------------------------------------------

---------------------------------------------------------------------------
-- REFRESH
-- Esta función se llama cada vez que el widget necesita ser redibujado.
-- Aquí es donde se debe implementar toda la lógica de dibujo del widget,
-- utilizando las opciones configuradas en la tabla de opciones.
-- El widget se dibuja dentro de la zona (zone) que se le asignó, y puede
-- acceder a las opciones para mostrar la información correspondiente.
-- Es importante optimizar esta función para que el widget se dibuje de
-- manera eficiente y sin causar retrasos en la interfaz.
---------------------------------------------------------------------------

local function refresh(widget)
    -- La zona asignada al widget, que contiene las coordenadas (x, y) y
    -- dimensiones (w, h) para dibujar el widget.
    local z = widget.zone

    -- Las opciones configuradas por el usuario para el widget, que pueden
    -- incluir interruptores, fuentes de datos, etc. Estas opciones se pueden usar
    -- para personalizar la apariencia y el comportamiento del widget según
    -- las preferencias del usuario.
    local opt = widget.options

    -- Dibuja un fondo sólido para el widget, con un rectángulo
    lcd.drawFilledRectangle(z.x, z.y, z.w, z.h, BLACK)

    -- Dibuja un rectángulo gris en la parte superior del widget para mostrar
    -- la información principal, como el estado del motor, el estado de armado,
    -- el modo de vuelo, el nombre del modelo, etc. Este rectángulo sirve como
    -- fondo para resaltar esta información y mejorar su legibilidad.
    lcd.drawFilledRectangle(z.x, z.y, z.w, 45, GREY)


    local rssVal   = 0 -- Valor de RSSI, que se obtiene de la fuente de datos "1RSS".
    -- Si no se obtiene un valor válido, se establece en 0. Este valor se utiliza
    -- para determinar el color de la información mostrada en el widget,
    -- como el estado del motor, el estado de armado, el modo de vuelo, etc.
    -- Si el valor de RSSI es 0, se muestra en blanco; si es diferente de 0,
    -- se muestra en rosa (ROSA). Además, el valor de RSSI se muestra en la parte
    -- inferior del widget con un color que varía según la intensidad de la señal:
    -- verde para buena señal, amarillo para señal media y rojo para señal débil.

    local rxSignal = getValue("1RSS") or 0

    if rxSignal ~= nil and rxSignal ~= 0 then
        rssVal = getValue("1RSS") or 0
    end

    -- Obtener el estado de los interruptores configurados en las opciones del widget
    local motorOn = getValue(opt.Motor)
    local armOn   = getValue(opt.Arm)
    local modeOn  = getValue(opt.Modo)
    local revo    = getValue(opt.Revo)


    -- Determinar los colores y textos a mostrar según el estado de los interruptores
    local baseColor
    if rssVal == 0 then
        baseColor = WHITE
    else
        baseColor = ROSA
    end

    local armColor
    local armText
    if armOn > 0 then
        armText = "Armado"
        armColor = RED
    else
        armText = "Desarmado"
        armColor = baseColor
    end

    local modeColor
    local modeText
    if modeOn > 0 then
        modeText = "Estable"
        modeColor = GREEN
    else
        modeText = "Acro"
        modeColor = RED
    end

    local motorText = "MOTOR"
    local motorColor = baseColor
    if motorOn > 0 then
        motorText = "Motor SI"
        motorColor = RED
    else
        motorText = "Motor NO"
        motorColor = baseColor
    end


    local revoText
    local revoColor

    if revo > 0 then
        revoText = "Revo 3"
        revoColor = RED
    elseif revo < 0 then
        revoText = "Revo 1"
        revoColor = GREEN
    else
        revoText = "Revo 2"
        revoColor = YELLOW
    end


    -- Dibuja la información principal en la parte superior del widget,
    -- utilizando los colores determinados por el estado de los interruptores
    -- y el valor de RSSI. Esta información incluye el estado del motor,
    -- el estado de armado, el modo de vuelo, el nombre del modelo, etc.

    lcd.drawText(z.x + 55, z.y + 8, motorText, MIDSIZE + motorColor)
    lcd.drawText(z.x + 200, z.y + 8, armText, MIDSIZE + armColor)
    lcd.drawText(z.x + z.w - 200, z.y + (z.h - 90), revoText, DBLSIZE + ((rssVal ~= 0) and ROSA or revoColor))
    lcd.drawText(z.x + z.w - 10, z.y + 8, model.getInfo().name or "MODELO",
        RIGHT + MIDSIZE + ((rssVal ~= 0) and ROSA or WHITE))

    lcd.drawText(z.x + z.w - 320, z.y + (z.h - 90), modeText, DBLSIZE + modeColor)

    -- Dibuja la imagen del widget en la parte derecha, si se cargó correctamente.
    if widget.bmp then
        lcd.drawBitmap(widget.bmp, z.x + z.w - 270, z.y + 55)
    else
        lcd.drawText(z.x + z.w - 320, z.y + 30, widget.errorMsg or "Sin imagen", WHITE)
    end

    -- Dibuja la información de RSSI y calidad de señal en la parte inferior del widget,
    -- utilizando colores que varían según la intensidad de la señal. El valor de RSSI
    -- se muestra en decibelios (dB) y la calidad de señal se muestra en porcentaje (%).
    -- Si el valor de RSSI es 0, se muestra en blanco; si es diferente de 0, se muestra en rosa.
    -- Además, el color del texto varía según la intensidad de la señal: verde para buena señal,
    -- amarillo para señal media y rojo para señal débil. Esta información es importante para que
    -- el usuario pueda monitorear la calidad de la conexión entre el transmisor y el receptor,
    -- lo que puede afectar el rendimiento y la seguridad del vuelo.

    local rqtyVal = getValue("RQly") or 0

    local rssColor = (rssVal > -80) and GREEN or ((rssVal > -90) and YELLOW or RED)
    lcd.drawText((z.x + (z.w / 8 * 1)), z.y + (z.h - 45), string.format("%ddB", rssVal),
        CENTER + ((rssVal ~= 0) and rssColor or WHITE))
    lcd.drawText((z.x + (z.w / 8 * 1)), z.y + (z.h - 25), "1RSS",
        CENTER + ((rssVal ~= 0) and rssColor or WHITE))


    local rqtyColor = (rqtyVal > 98) and GREEN or ((rqtyVal > 90) and YELLOW or RED)
    lcd.drawText((z.x + (z.w / 8 * 2)), z.y + (z.h - 45), string.format("%d%%", rqtyVal),
        CENTER + ((rssVal ~= 0) and rqtyColor or WHITE))
    lcd.drawText((z.x + (z.w / 8 * 2)), z.y + (z.h - 25), "RQly",
        CENTER + ((rssVal ~= 0) and rqtyColor or WHITE))


    -- Dibuja la información de potencia de transmisión (TPWR) recibida por el receptor,
    -- utilizando colores que varían según el nivel de potencia. El valor de potencia
    -- se muestra en miliwatios (mW). Si el valor de potencia es 0, se muestra en blanco;
    -- si es diferente de 0, se muestra en rosa. Además, el color del texto varía según el
    -- nivel de potencia: verde para buena potencia, amarillo para potencia media y rojo
    -- para potencia baja.

    local tpwrVal = getValue("TPWR") or 0
    local tpwrColor = (tpwrVal > 200) and GREEN or ((tpwrVal > 99) and YELLOW or RED)
    lcd.drawText((z.x + (z.w / 8 * 3)), z.y + (z.h - 45), string.format("%dmW", tpwrVal),
        CENTER + ((rssVal ~= 0) and tpwrColor or WHITE))
    lcd.drawText((z.x + (z.w / 8 * 3)), z.y + (z.h - 25), "TPWR",
        CENTER + ((rssVal ~= 0) and tpwrColor or WHITE))



    -- información de la intensidad de la señal que recibe el transmisor desde la telemetría del
    -- receptor, utilizando colores que varían según la intensidad de la señal. El valor de intensidad
    -- se muestra en decibelios (dB). Si el valor de intensidad es 0, se muestra en blanco;
    -- si es diferente de 0, se muestra en rosa. Además, el color del texto varía según la intensidad
    -- de la señal: verde para buena señal, amarillo para señal media y rojo para señal débil.

    local trssVal = getValue("TRSS") or 0
    local trssColor = (trssVal > -80) and GREEN or ((trssVal > -90) and YELLOW or RED)
    lcd.drawText((z.x + (z.w / 8 * 4)), z.y + (z.h - 45), string.format("%ddB", trssVal),
        CENTER + ((rssVal ~= 0) and trssColor or WHITE))
    lcd.drawText((z.x + (z.w / 8 * 4)), z.y + (z.h - 25), "TRSS",
        CENTER + ((rssVal ~= 0) and trssColor or WHITE))


    -- Dibuja la información de calidad de enlace (TQly) recibida por el transmisor desde
    -- la telemetría del receptor, utilizando colores que varían según la calidad del enlace.
    -- El valor de calidad se muestra en porcentaje (%). Si el valor de calidad es 0, se muestra
    -- en blanco; si es diferente de 0, se muestra en rosa. Además, el color del texto varía
    -- según la calidad del enlace: verde para buena calidad, amarillo para calidad media y
    -- rojo para calidad baja.

    local tqlyVal = getValue("TQly") or 0
    local tqlyColor = (tqlyVal > 98) and GREEN or ((tqlyVal > 90) and YELLOW or RED)
    lcd.drawText((z.x + (z.w / 8 * 5)), z.y + (z.h - 45), string.format("%d%%", tqlyVal),
        CENTER + ((rssVal ~= 0) and tqlyColor or WHITE))
    lcd.drawText((z.x + (z.w / 8 * 5)), z.y + (z.h - 25), "TQly",
        CENTER + ((rssVal ~= 0) and tqlyColor or WHITE))


    --Corriente consumida por el helicóptero
    local currVal = getValue("Curr") or 0
    lcd.drawText((z.x + (z.w / 8 * 6)), z.y + (z.h - 45), string.format("%.2fA", currVal),
        CENTER + ((rssVal ~= 0) and GREEN or WHITE))
    lcd.drawText((z.x + (z.w / 8 * 6)), z.y + (z.h - 25), "Corr",
        CENTER + ((rssVal ~= 0) and GREEN or WHITE))


    -- Temperatura del ESC del helicóptero,
    local tescVal = getValue("Tesc") or 0
    local tescColor = (tescVal > 50) and RED or ((tescVal > 45) and YELLOW or GREEN)
    lcd.drawText((z.x + (z.w / 8 * 7)), z.y + (z.h - 45), string.format("%d°C", tescVal),
        CENTER + ((rssVal ~= 0) and tescColor or WHITE))
    lcd.drawText((z.x + (z.w / 8 * 7)), z.y + (z.h - 25), "TESC",
        CENTER + ((rssVal ~= 0) and tescColor or WHITE))


    -- Velocidad de rotación del rotor principal (rpm H) y del rotor de cola (rpm T) del helicóptero,
    -- utilizando colores que varían según el valor de RSSI. Si el valor de RSSI es 0,
    -- se muestra en blanco; si es diferente de 0, se muestra en rosa.

    local RpmHVal = getValue("Hspd") or 0
    lcd.drawText(z.x + 5, z.y + 50, "rpm H", SMLSIZE + LEFT + BOLD + ((rssVal ~= 0) and ROSA or WHITE))
    lcd.drawText(z.x + 80, z.y + 45, string.format("%d", RpmHVal),
        MIDSIZE + LEFT + BOLD + ((rssVal ~= 0) and ROSA or WHITE))

    local RpmTVal = getValue("Tspd") or 0
    lcd.drawText(z.x + 5, z.y + 75, "rpm T", SMLSIZE + LEFT + BOLD + ((rssVal ~= 0) and ROSA or WHITE))
    lcd.drawText(z.x + 80, z.y + 70, string.format("%d", RpmTVal),
        MIDSIZE + LEFT + BOLD + ((rssVal ~= 0) and ROSA or WHITE))



    -- TIMER

    -- Este bloque de código implementa un temporizador que se inicia cuando el helicóptero está armado,
    -- el motor está encendido y la velocidad del rotor principal (rpm H) es mayor que 0.
    -- El temporizador se muestra en formato minutos:segundos (MM:SS) en la parte inferior del widget.
    -- Si alguna de las condiciones para iniciar el temporizador no se cumple, el temporizador se pausa.
    -- El tiempo transcurrido se actualiza solo cuando el temporizador está corriendo,
    -- y se muestra con un color que varía según el valor de RSSI: rosa si RSSI es diferente de 0,
    -- o blanco si RSSI es 0.

    if armOn > 0 and motorOn > 0 and RpmHVal > 0 then
        --correr
        if not running then
            running = true
            startTime = getTime() - elapsed -- reanudar desde donde quedó
        end
    else
        --pausar
        running = false
    end

    -- Actualizar tiempo si está corriendo
    if running then
        elapsed = getTime() - startTime
    end

    -- Convertir a minutos:segundos
    local minutos = math.floor(elapsed / 6000) -- 6000 milésimas = 60s
    local segundos = math.floor((elapsed % 6000) / 100)

    -- Mostrar tiempo en formato MM:SS
    lcd.drawText(z.x + z.w - 10, z.y + (z.h - 90), string.format("%02d:%02d", minutos, segundos),
        RIGHT + DBLSIZE + ((rssVal ~= 0) and ((running) and YELLOW or ROSA) or WHITE))

    -- TX VOLTAJE 
    -- Este bloque de código muestra la información del voltaje de la batería del transmisor
    -- (Tx Voltage) en la parte inferior derecha del widget.
    -- El valor del voltaje se obtiene de la fuente de datos "tx-voltage". Si el valor de voltaje
    -- es mayor que 7.5V, se muestra en verde; si es mayor que 6.8V pero menor o igual a 7.5V,
    -- se muestra en amarillo y parpadea; si es menor o igual a 6.8V, se muestra en rojo oscuro y parpadea.

    local txV = getValue("tx-voltage") or 0

    local txvColor
    local destello
    if txV > 7.5 then
        txvColor = GREEN
        destello = 0
    elseif txV > 6.8 then
        txvColor = YELLOW
        destello = BLINK
    else
        txvColor = DARKRED
        destello = BLINK
    end

    lcd.drawText(z.x + z.w - 10, z.y + (z.h - 130), string.format("Tx Bat %.1fV", txV),
        RIGHT + MIDSIZE + txvColor + destello)

    
    -- RX BATERÍA
    -- Este bloque de código muestra la información del voltaje por celda de la batería del receptor
    -- (Rx Battery) en la parte inferior izquierda del widget.
    -- El valor del voltaje por celda se obtiene de la fuente de datos "Vcel".
    -- El porcentaje de voltaje se calcula en función de un rango típico de voltaje por celda
    -- (3.3V a 4.2V) y se muestra como un icono de batería con un color que varía según el
    -- porcentaje: verde para más del 50%, amarillo para entre 30% y 50%, y rojo para menos del 30%.
    -- Si el porcentaje es menor o igual al 30%, el icono parpadea para alertar al usuario sobre
    -- el bajo nivel de batería. Además, el valor del voltaje por celda se muestra en texto debajo
    -- del icono de la batería.
    local vPerCell = getValue("Vcel") or 0
    -- 
    local vMin = 3.3
    local vMax = 4.2

    local vPercent = (vPerCell - vMin) / (vMax - vMin)
    vPercent = math.max(0, math.min(1, vPercent))

    -- Determinar el color del icono de la batería según el porcentaje de voltaje por celda
    local vColor = GREEN
    local flash = false

    if vPercent <= 0.30 then
        vColor = RED
        flash = true
    elseif vPercent <= 0.50 then
        vColor = YELLOW
    end

    if flash and (getTime() % 20 < 10) then
        vColor = BLACK
    end

    -- Dibujar el icono de la batería y el voltaje por celda en la parte inferior izquierda del widget
    local battW = 150
    local battH = 45
    local battX = z.x + 6
    local battY = z.y + 110

    drawBatteryIcon(battX, battY, battW, battH, vPercent, vColor)

    local textX = battX + battW / 2
    local textY = battY + 12

    lcd.drawText(textX, textY, string.format("%.2fV", vPerCell), CENTER + WHITE + BOLD)


    -- porcentaje restante de la batería del receptor, que se obtiene de la fuente de
    -- datos "Bat%". El porcentaje se muestra debajo del icono de la batería con un color que varía
    -- según el nivel de batería: verde para más del 50%, amarillo para entre 30% y 50%, y rojo para
    -- menos del 30%. Si el porcentaje es menor o igual al 30%, el texto parpadea para
    -- alertar al usuario sobre el bajo nivel de batería.

    local batPercent = getValue("Bat%") or 0
    local batColor = BLUE
    if batPercent <= 50 then
        batColor = RED
    end

    lcd.drawGauge(battX, battY + battH + 5, battW, 20, batPercent, 100, batColor)
    lcd.drawText(textX, textY + 38, string.format("%d%%", batPercent), CENTER + WHITE)

    -- capacidad restante de la batería del receptor, que se obtiene de la fuente de datos "Capa".
    -- El valor de capacidad se muestra debajo del porcentaje de batería con un color que varía
    -- según el nivel de capacidad: verde para más de 500mAh, amarillo para entre 200mAh y 500mAh,
    -- y rojo para menos de 200mAh. Si la capacidad es menor o igual a 200mAh, el texto parpadea
    -- para alertar al usuario sobre el bajo nivel de batería.

    local capaVal = getValue("Capa") or 0

    lcd.drawGauge(battX, battY + battH + 30, battW, 20, capaVal, 750, BROWN)
    lcd.drawText(textX, textY + 63, string.format("%dmA", capaVal), CENTER + WHITE)
    
end
---------------------------------------------------------------------------
--- RETURN
--- Esta función devuelve una tabla con el nombre del widget y las funciones
--- de creación, actualización, refresco y opciones. Esta tabla es lo que el
--- sistema de widgets de EdgeTX utiliza para gestionar el widget. El nombre
--- del widget  es una cadena que identifica el widget, y las funciones son
--- las que se han definido anteriormente para crear, actualizar, refrescar
--- y manejar las opciones del widget. Al registrar el widget, EdgeTX llamará
--- a estas funciones en los momentos apropiados para gestionar la vida del
--- widget, desde su creación hasta su actualización y redibujo en la pantalla.
---------------------------------------------------------------------------

return {
    name = name,
    create = create,
    refresh = refresh,
    update = update,
    options = options
}


--[[


local name = "gooskyS2"

-- Lista de sensores a mostrar en texto
local sensors = {
    "Alt",    -- Altitud
    "GPS",    -- Coordenadas GPS
    "Tmp1",   -- Temperatura 1
    "Tmp2",   -- Temperatura 2
    "Fuel",   -- Combustible
    "RPM",    -- Revoluciones
    "AccX",   -- Acelerómetro X
    "AccY",   -- Acelerómetro Y
    "AccZ"    -- Acelerómetro Z
}

-- Función para dibujar un gauge circular
-- Recibe posición (x,y), radio, valor actual y rango máximo
local function drawGauge(x, y, r, value, max, label)
    -- Dibuja círculo base
    lcd.drawCircle(x, y, r, SOLID, FORCE)
    -- Calcula ángulo proporcional al valor
    local angle = math.floor((value / max) * 270) - 135
    local rad = math.rad(angle)
    local gx = x + math.floor(r * math.cos(rad))
    local gy = y + math.floor(r * math.sin(rad))
    -- Dibuja aguja
    lcd.drawLine(x, y, gx, gy, SOLID, FORCE)
    -- Etiqueta y valor
    lcd.drawText(x - r, y + r + 5, label .. ": " .. tostring(value), 0)
end

-- Función create: inicializa el widget
local function create(zone, options)
    return { zone=zone, options=options }
end

-- Función update: actualiza opciones si cambian
local function update(widget, options)
    widget.options = options
end

-- Función refresh: dibuja gauges y lista de sensores
local function refresh(widget)
    lcd.clear()

    -- Gauges principales
    local volt = getValue("VFAS") or 0
    local curr = getValue("Curr") or 0
    local rssi = getValue("RSSI") or 0

    -- Dibuja tres gauges en la parte superior
    drawGauge(widget.zone.x + 40, widget.zone.y + 40, 30, volt, 25, "Volt")
    drawGauge(widget.zone.x + 120, widget.zone.y + 40, 30, curr, 50, "Amp")
    drawGauge(widget.zone.x + 200, widget.zone.y + 40, 30, rssi, 100, "RSSI")

    -- Lista de sensores adicionales en texto
    local y = widget.zone.y + 90
    for i, s in ipairs(sensors) do
        local val = getValue(s)
        lcd.drawText(widget.zone.x, y, s .. ": " .. tostring(val), 0)
        y = y + 12
    end
end

-- Registro del widget
return { name=name, create=create, update=update, refresh=refresh }
]]
