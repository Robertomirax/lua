---------------------------------------------------------------------------
---Widget para Goosky S2 y Radiomaster TX16S mk2
-- Versión de Roberto Domingues
-- EdgeTX 2.11+
---------------------------------------------------------------------------
---
---@diagnostic disable: undefined-global
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- variables globales
----------------------------------------------------------------------------
-- Esta sección se utiliza para definir variables globales que pueden ser
-- utilizadas en todo el widget. Estas variables pueden almacenar información
-- como colores, imágenes, estados, etc. En este caso, se definen dos colores
-- personalizados, BROWN y PINK, utilizando la función lcd.RGB para crear
-- colores específicos que se utilizarán en el widget. Estas variables
-- globales permiten que el widget tenga una apariencia personalizada y
-- consistente en toda su interfaz, y facilitan la reutilización de valores
-- que se necesitan en diferentes partes del código, como en la función de
-- refresco para dibujar elementos con los colores definidos.
---------------------------------------------------------------------------

local BROWN = lcd.RGB(79, 54, 39)
local PINK = lcd.RGB(206, 126, 252)

---------------------------------------------------------------------------
--- Funciones auxiliares. Estas funciones se utilizan para realizar tareas
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
---------------------------------------------------------------------------
-- IMAGE funciones para cargar imágenes desde la carpeta IMAGES del widget.
-- La función pngFilename se encarga de verificar si el nombre de la imagen
-- tiene la extensión .png, y si no, se la agrega automáticamente.
-- La función loadImage intenta cargar la imagen especificada y almacena el
-- resultado en la variable bm. Si la imagen se carga correctamente,
-- devuelve true; de lo contrario, devuelve false.
-- Estas funciones permiten al widget mostrar una imagen personalizada en la
-- pantalla, lo que puede mejorar la apariencia y proporcionar información
-- visual adicional al usuario. Es importante asegurarse de que las imágenes
-- estén en la carpeta correcta y tengan el formato adecuado para que se
-- carguen correctamente en el widget.
----------------------------------------------------------------------------
-- Verificar si la imagen tiene extensión .png, si no, agregarla
local bm = nil

local function pngFilename(imgName)
    if not imgName or imgName == "" then return nil end

    if not string.match(imgName, "%.png$") then
        imgName = imgName .. ".png"
    end

    return imgName
end


local function loadImage(imgName)
    bm = nil

    if not imgName or imgName == "" then return false end

    local filename = pngFilename(imgName)
    local path = "/IMAGES/" .. filename

    local ok, img = pcall(Bitmap.open, path)

    if ok and img then
        bm = img
        return true
    end

    return false
end

---------------------------------------------------------------------------
-- SOURCE LABEL FUNCTION
---------------------------------------------------------------------------
local function sourceLabel(src, fallback)
    if src ~= 0 then
        local info = getSourceInfo(src)
        if info and info.name then
            return info.name
        end
    end
    return fallback
end

---------------------------------------------------------------------------
-- BATTERY ICON
---------------------------------------------------------------------------
local function drawBatteryIcon(x, y, w, h, percent, color)
    lcd.drawRectangle(x, y, w, h, WHITE)
    lcd.drawFilledRectangle(x + w, y + h / 3, 4, h / 3, WHITE)
    lcd.drawFilledRectangle(x + 1, y + 1, (w - 2) * percent, h - 2, color)
end





---------------------------------------------------------------------------
--- Primer campo obligatorio: NAME  (string)
--- 
-- Esta variable define el nombre del widget, que se mostrará en la interfaz
-- de configuración y en la lista de widgets disponibles. Es importante
-- elegir un nombre descriptivo y único para que los usuarios puedan
-- identificar fácilmente el widget y su función. El nombre también puede
-- ser utilizado en el código para referirse al widget, por lo que es
-- recomendable evitar caracteres especiales o espacios en blanco que puedan
-- causar problemas de sintaxis. En este caso, el widget se llama "gooskyS2",
-- lo que sugiere que está diseñado para mostrar información relacionada
-- con el helicóptero Goosky S2 y la radio Radiomaster TX16S mk2.
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
---------------------------------------------------------------------------

local options = {
    { "Arm",       SWITCH, 0 },
    { "Motor",     SWITCH, 0 },
    { "Modo",      SWITCH, 0 },
    { "Rx Signal", SOURCE, 0 }, --1RSS
    { "Rx Qly",    SOURCE, 0 },
    { "RpmH",      SOURCE, 0 },
    { "RpmT",      SOURCE, 0 },
    { "Curr",      SOURCE, 0 },
    { "Tesc",      SOURCE, 0 },
    { "Vcel",      SOURCE, 0 },
    { "Bat%",      SOURCE, 0 },
    { "Capa",      SOURCE, 0 },
    { "Tpwr",      SOURCE, 0 },
    { "Trss",      SOURCE, 0 }, --TRSS
    { "Tqly",      SOURCE, 0 }, --TQly
}



---------------------------------------------------------------------------
--- Tercer campo (obligatorio): CREATE (función)
--- 
--Esta función se llama una sola vez cuando se registra (se inicia) la
--instancia del widget. Aquí es donde se deben inicializar las variables,
--cargar recursos, cargar imágenes, etc. El widget se crea con una zona
--(zone) y opciones (opts) que se definen en la tabla de opciones.
-- el parametro zone es un objeto que contiene las coordenadas y dimensiones
-- de la zona asignada al widget en la pantalla. El widget puede usar esta
-- información para dibujar su contenido dentro de esa zona específica.
-- El parámetro opts es una tabla que contiene las opciones configuradas
-- por el usuario para el widget, como los interruptores, fuentes de datos,
-- etc. Estas opciones se pueden usar para personalizar la apariencia y el
-- comportamiento del widget según las preferencias del usuario. En esta
-- función, también se puede cargar una imagen personalizada para el widget
-- utilizando la función loadImage, lo que permite mostrar gráficos o iconos
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
    local w = { zone = zone, options = opts or {} }

    local modelName = model.getInfo().name
    --loadImage(modelName)
    loadImage("S2t.png")
    return w
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
-- utilizando utilizando las opciones configuradas en la tabla de opciones.
-- El widget se dibuja dentro de la zona (zone) que se le asignó, y puede
-- acceder a las opciones para mostrar la información correspondiente.
-- Es importante optimizar esta función para que el widget se dibuje de
-- manera eficiente y sin causar retrasos en la interfaz.
---------------------------------------------------------------------------

local function refresh(widget)
    local z   = widget.zone
    local opt = widget.options

    lcd.drawFilledRectangle(z.x, z.y, z.w, z.h, BLACK)
    lcd.drawFilledRectangle(z.x, z.y, z.w, 45, GREY)

    ---------------------------------------------------------------------------
    -- MOTOR / ARM / FM / MODEL NAME
    ---------------------------------------------------------------------------

    local rssVal   = 0
    local rxSignal = opt["Rx Signal"]

    if rxSignal ~= nil and rxSignal ~= 0 then
        rssVal = getValue(rxSignal)
    end

    local motorOn = opt.Motor ~= 0 and getSwitchValue(opt.Motor) == true
    local armOn   = opt.Arm ~= 0 and getSwitchValue(opt.Arm) == true
    local modeOn  = opt.Modo ~= 0 and getSwitchValue(opt.Modo) == true
    local fm      = getFlightMode() or 0

    local texts   = {
        motorOn and "MOTOR SI" or "MOTOR NO",
        armOn and "ARMADO" or "DESARMADO",
        "Idle-" .. fm,
        modeOn and "Estable" or "Acro"
    }

    local baseColor
    if rssVal == 0 then
        baseColor = WHITE
    else
        baseColor = PINK
    end

    local motorColor = motorOn and RED or baseColor
    local armColor   = armOn and RED or baseColor
    local modeColor  = modeOn and GREEN or RED

    lcd.drawText(z.x + 55, z.y + 8, texts[1], MIDSIZE + motorColor)
    lcd.drawText(z.x + 200, z.y + 8, texts[2], MIDSIZE + armColor)
    lcd.drawText(z.x + z.w - 200, z.y + (z.h - 90), texts[3], DBLSIZE + ((rssVal ~= 0) and PINK or WHITE))
    lcd.drawText(z.x + z.w - 10, z.y + 8, model.getInfo().name or "MODELO",
        RIGHT + MIDSIZE + ((rssVal ~= 0) and PINK or WHITE))

    lcd.drawText(z.x + z.w - 320, z.y + (z.h - 90), texts[4], DBLSIZE + modeColor)

    if bm then
        lcd.drawBitmap(bm, z.x + z.w - 320, z.y + 30)
    end

    ---------------------------------------------------------------------------
    -- OPTIONS / TELEMTERY VALUES
    ---------------------------------------------------------------------------
    local rqtyVal  = (opt["Rx Qly"] ~= 0 and getValue(opt["Rx Qly"])) or 0
    local tescVal  = (opt["Tesc"] ~= 0 and getValue(opt["Tesc"])) or 0
    local currVal  = (opt["Curr"] ~= 0 and getValue(opt["Curr"])) or 0
    local RpmHVal  = (opt["RpmH"] ~= 0 and getValue(opt["RpmH"])) or 0
    local RpmTVal  = (opt["RpmT"] ~= 0 and getValue(opt["RpmT"])) or 0
    local vPerCell = (opt["Vcel"] ~= 0 and getValue(opt["Vcel"])) or 0
    local tpwrVal  = (opt["Tpwr"] ~= 0 and getValue(opt["Tpwr"])) or 0
    local trssVal  = (opt["Trss"] ~= 0 and getValue(opt["Trss"])) or 0
    local tqlyVal  = (opt["Tqly"] ~= 0 and getValue(opt["Tqly"])) or 0

    local rssColor = (rssVal > -80) and GREEN or ((rssVal > -90) and YELLOW or RED)
    lcd.drawText((z.x + (z.w / 8 * 1)), z.y + (z.h - 45), string.format("%ddB", rssVal),
        CENTER + ((rssVal ~= 0) and rssColor or WHITE))
    lcd.drawText((z.x + (z.w / 8 * 1)), z.y + (z.h - 25), sourceLabel(opt["Rx Signal"], "1RSS"),
        CENTER + ((rssVal ~= 0) and rssColor or WHITE))

    local rqtyColor = (rqtyVal > 98) and GREEN or ((rqtyVal > 90) and YELLOW or RED)
    lcd.drawText((z.x + (z.w / 8 * 2)), z.y + (z.h - 45), string.format("%d%%", rqtyVal),
        CENTER + ((rssVal ~= 0) and rqtyColor or WHITE))
    lcd.drawText((z.x + (z.w / 8 * 2)), z.y + (z.h - 25), sourceLabel(opt["Rx Qly"], "RQly"),
        CENTER + ((rssVal ~= 0) and rqtyColor or WHITE))

    local tpwrColor = (tpwrVal > 200) and GREEN or ((tpwrVal > 99) and YELLOW or RED)
    lcd.drawText((z.x + (z.w / 8 * 3)), z.y + (z.h - 45), string.format("%dmW", tpwrVal),
        CENTER + ((rssVal ~= 0) and tpwrColor or WHITE))
    lcd.drawText((z.x + (z.w / 8 * 3)), z.y + (z.h - 25), sourceLabel(opt["Tpwr"], "TPWR"),
        CENTER + ((rssVal ~= 0) and tpwrColor or WHITE))

    local trssColor = (trssVal > -80) and GREEN or ((trssVal > -90) and YELLOW or RED)
    lcd.drawText((z.x + (z.w / 8 * 4)), z.y + (z.h - 45), string.format("%ddB", trssVal),
        CENTER + ((rssVal ~= 0) and trssColor or WHITE))
    lcd.drawText((z.x + (z.w / 8 * 4)), z.y + (z.h - 25), sourceLabel(opt["Trss"], "TRSS"),
        CENTER + ((rssVal ~= 0) and trssColor or WHITE))

    local tqlyColor = (tqlyVal > 98) and GREEN or ((tqlyVal > 90) and YELLOW or RED)
    lcd.drawText((z.x + (z.w / 8 * 5)), z.y + (z.h - 45), string.format("%d%%", tqlyVal),
        CENTER + ((rssVal ~= 0) and tqlyColor or WHITE))
    lcd.drawText((z.x + (z.w / 8 * 5)), z.y + (z.h - 25), sourceLabel(opt["Tqly"], "TQly"),
        CENTER + ((rssVal ~= 0) and tqlyColor or WHITE))

    lcd.drawText((z.x + (z.w / 8 * 6)), z.y + (z.h - 45), string.format("%.2fA", currVal),
        CENTER + ((rssVal ~= 0) and GREEN or WHITE))
    lcd.drawText((z.x + (z.w / 8 * 6)), z.y + (z.h - 25), sourceLabel(opt["Curr"], "Corr"),
        CENTER + ((rssVal ~= 0) and GREEN or WHITE))

    local tescColor = (tescVal > 50) and RED or ((tescVal > 45) and YELLOW or GREEN)
    lcd.drawText((z.x + (z.w / 8 * 7)), z.y + (z.h - 45), string.format("%d°C", tescVal),
        CENTER + ((rssVal ~= 0) and tescColor or WHITE))
    lcd.drawText((z.x + (z.w / 8 * 7)), z.y + (z.h - 25), sourceLabel(opt["Tesc"], "TESC"),
        CENTER + ((rssVal ~= 0) and tescColor or WHITE))


    ---------------------------------------------------------------------------
    -- RPM
    ---------------------------------------------------------------------------

    lcd.drawText(z.x + 5, z.y + 50, "rpm H", SMLSIZE + LEFT + BOLD + ((rssVal ~= 0) and PINK or WHITE))
    lcd.drawText(z.x + 80, z.y + 45, string.format("%d", RpmHVal),
        MIDSIZE + LEFT + BOLD + ((rssVal ~= 0) and PINK or WHITE))

    lcd.drawText(z.x + 5, z.y + 75, "rpm T", SMLSIZE + LEFT + BOLD + ((rssVal ~= 0) and PINK or WHITE))
    lcd.drawText(z.x + 80, z.y + 70, string.format("%d", RpmTVal),
        MIDSIZE + LEFT + BOLD + ((rssVal ~= 0) and PINK or WHITE))


    ---------------------------------------------------------------------------
    -- TIMER
    ---------------------------------------------------------------------------

    local timer = model.getTimer(0) --Timer 1 (index starts at 0)
    local timeLeft = timer.value or 0

    lcd.drawText(z.x + z.w - 10, z.y + (z.h - 90), string.format("%02d:%02d", math.floor(timeLeft / 60), timeLeft % 60),
        RIGHT + DBLSIZE + ((rssVal ~= 0) and YELLOW or WHITE))

    ---------------------------------------------------------------------------
    -- TX VOLTAGE
    ---------------------------------------------------------------------------
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

    -------------------------------------------------------------------------
    -- RX BATTERY
    -------------------------------------------------------------------------


    -- VBAT Voltage → Percentage
    local vMin = 3.3
    local vMax = 4.2

    local vPercent = (vPerCell - vMin) / (vMax - vMin)
    vPercent = math.max(0, math.min(1, vPercent))

    -- VBAT Color + flash logic
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

    -- DRAW BATTERY ICON
    local battW = 150
    local battH = 45
    local battX = z.x + 6
    local battY = z.y + 110

    drawBatteryIcon(battX, battY, battW, battH, vPercent, vColor)

    local textX = battX + battW / 2
    local textY = battY + 12

    lcd.drawText(textX, textY, string.format("%.2fV", vPerCell), CENTER + WHITE + BOLD)


    -- porcentaje de batería
    local batPercent = getValue(opt["Bat%"]) or 0
    local batColor = BLUE
    if batPercent <= 50 then
        batColor = RED
    end

    lcd.drawGauge(battX, battY + battH + 5, battW, 20, batPercent, 100, batColor)
    lcd.drawText(textX, textY + 38, string.format("%d%%", batPercent), CENTER + WHITE)

    -- capacidad de la batería
    local capaVal = getValue(opt["Capa"]) or 0

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
