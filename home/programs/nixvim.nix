{ inputs, ... }: {
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];
 
  programs.nixvim = {
    enable = true;

    diagnostic.settings = {
      virtual_lines = {
	current_line = true;
      };
      virtual_text = true;
    };

    opts = {
      relativenumber = true;
      shiftwidth = 2;
    }; 

    globals = {
      mapleader = " ";
    };

    clipboard.providers.wl-copy.enable = true;
    colorschemes.rose-pine.enable = true;

    plugins = {
      lualine.enable = true;
      nvim-autopairs.enable = true;
      lspconfig.enable = true;
      blink-cmp.enable = true;
      treesitter = {
	enable = true;
	settings = {
	  auto_install = true;
	};
      };
      noice.enable = true;
      luasnip.enable = true;
      telescope.enable = true;
      trouble = {
	enable = true;
	settings = {
	  focus = true;
	  warn_no_results = false;
	};
      };
      which-key.enable = true;
      web-devicons.enable = true;
      snacks.enable = true;
      markview.enable = true;
    };

    plugins.lsp = {
      enable = true;
      servers = {
	nixd.enable = true; 
	clangd.enable = true;
	pyright.enable = true;
	gopls.enable = true;
	rust_analyzer = {
	  enable = true;
	  installCargo = true;
	  installRustc = true;
	  installRustfmt = true;
	};
      };
    };

    keymaps = [
      {
	action = "<cmd>Telescope live_grep<CR>";
	key = "<leader><leader>";
      }
      {
	action = "<cmd>Trouble diagnostics toggle<cr>";
	key = "<leader>x";
      }

      # Snacks
      {
	action = "<cmd>lua Snacks.picker.buffers()<CR>";
	key = "<leader>,";
	options.desc = "Buffer";
      }
      {
	action = "<cmd>lua Snacks.scratch()<CR>";
	key = "<leader>.";
	options.desc = "Scratch Buffer";
      }
      {
	action = "<cmd>lua Snacks.explorer()<CR>";
	key = "<leader>e";
	options.desc = "Explorer";
      } 
      {
	action = "<cmd>lua Snacks.picker.files()<CR>";
	key = "<leader>ff";
	options.desc = "Find Files";
      }
      {
	action = "<cmd>lua Snacks.picker.lsp_definitions()<CR>";
	key = "gd";
	options.desc = "Goto Definitions";
      }
      {
	action = "<cmd>lua Snacks.picker.lsp_declarations()<CR>";
	key = "gD";
	options.desc = "Goto Declaration";
      }
      {
	action = "<cmd>lua Snacks.zen()<CR>";
	key = "<leader>z";
	options.desc = "Zen Mode";
      } 
      {
	action = "<cmd>lua Snacks.terminal()<CR>";
	key = "<leader><return>";
	options.desc = "Terminal";
      }
      {
	action = "<cmd>lua Snacks.lazygit()<CR>";
	key = "<leader>gl";
	options.desc = "Lazygit";
      }
    ];
  };
}
