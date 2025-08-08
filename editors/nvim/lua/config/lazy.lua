-- Define la ruta donde se clonará lazy.nvim localmente
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- Verifica si lazy.nvim ya está clonado en la ruta especificada
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  -- URL del repositorio de Lazy.nvim
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"

  -- Ejecuta git clone del repositorio en la carpeta lazypath
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none", -- Clona sin historial pesado
    "--branch=stable", -- Usa la rama estable
    lazyrepo,
    lazypath,
  })

  -- Si ocurre un error al clonar el repositorio
  if vim.v.shell_error ~= 0 then
    -- Muestra un mensaje de error en Neovim
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})

    -- Espera una tecla antes de cerrar Neovim
    vim.fn.getchar()
    os.exit(1)
  end
end

-- Añade lazy.nvim al runtimepath de Neovim
vim.opt.rtp:prepend(lazypath)

-- Configura lazy.nvim con la tabla de opciones
require("lazy").setup({
  spec = {
    -- Carga LazyVim y sus plugins por defecto
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },

    -- Carga tus propios plugins desde la carpeta "lua/plugins/"
    { import = "plugins" },
  },

  defaults = {
    -- Si se deja en `false`, tus plugins se cargan al inicio (no lazy-loaded)
    lazy = false,

    -- Se recomienda dejarlo en false para evitar versiones antiguas que rompan Neovim
    version = false, -- Usa el último commit en lugar de una versión específica
    -- version = "*", -- (opcional) usar la versión estable más reciente compatible
  },

  -- Temas que se instalarán automáticamente si no hay uno configurado
  install = {
    colorscheme = { "catppuccin", "tokyonight", "habamax" },
  },

  -- Verifica periódicamente si hay actualizaciones de plugins
  checker = {
    enabled = true, -- Habilita la verificación automática
    notify = false, -- No mostrar notificaciones al actualizar
  },

  performance = {
    rtp = {
      -- Desactiva algunos plugins por defecto que no son necesarios
      disabled_plugins = {
        "gzip",
        -- "matchit",       -- opcional: habilita salto de etiquetas HTML
        -- "matchparen",    -- opcional: resalta paréntesis coincidentes
        -- "netrwPlugin",   -- desactivado si usas otro navegador de archivos
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
