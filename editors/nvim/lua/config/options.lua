-- Opciones de Neovim cargadas automáticamente antes de iniciar lazy.nvim
-- Las opciones por defecto están aquí: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Aquí puedes agregar tus propias opciones personalizadas

local set = vim.opt -- Alias para acceder a opciones globales de Neovim

--[[ Apariencia general ]]
set.colorcolumn = "80" -- Muestra una línea vertical en la columna 80 (útil como guía de ancho de línea)
set.termguicolors = true -- Habilita colores verdaderos en la terminal
set.background = "dark" -- Usa fondo oscuro en coloreschemes que lo soporten
set.signcolumn = "yes" -- Siempre muestra la columna de signos (git, errores, etc.)

--[[ Números de línea ]]
set.relativenumber = true -- Números relativos (líneas desde la posición actual)
set.number = true -- Muestra el número absoluto en la línea del cursor

--[[ Tabs e indentación ]]
set.tabstop = 2 -- Representa un tab como 2 espacios
set.shiftwidth = 2 -- Indentación al usar >> o << será de 2 espacios
set.expandtab = true -- Convierte tabs en espacios
set.autoindent = true -- Copia indentación de la línea anterior

--[[ Ajuste de líneas ]]
set.wrap = true -- Permite que las líneas largas se dividan visualmente (wrap)

--[[ Búsqueda ]]
set.ignorecase = true -- Ignora mayúsculas/minúsculas al buscar...
set.smartcase = true -- ...a menos que uses mayúsculas (hace búsqueda sensible al caso)

--[[ Línea del cursor ]]
set.cursorline = true -- Resalta la línea donde está el cursor

--[[ Retroceso ]]
set.backspace = "indent,eol,start" -- Permite borrar indentación, saltos de línea y texto antes del punto de inserción

--[[ Portapapeles ]]
set.clipboard = "unnamedplus" -- Usa el portapapeles del sistema por defecto

--[[ División de ventanas ]]
set.splitright = true -- Al dividir verticalmente, coloca la nueva ventana a la derecha
set.splitbelow = true -- Al dividir horizontalmente, coloca la nueva ventana abajo

--[[ Swapfile ]]
set.swapfile = false -- Desactiva archivos de swap (puede evitar conflictos o archivos basura)

--[[ Columnas opcionales ]]
-- set.textwidth = 120           -- (Desactivado) Define el ancho máximo para texto antes de hacer wrap automático

--[[ Animaciones de Snacks (comentado) ]]
-- vim.g.snacks_animate = false  -- Ejemplo de configuración global para plugin "snacks"

--[[ Inlay hints de LSP (Neovim < 0.10 compatibilidad opcional) ]]
-- if type(vim.lsp.inlay_hint) ~= "table" then
--   vim.lsp.inlay_hint = {
--     enable = function(_, _) end,
--   }
-- end
