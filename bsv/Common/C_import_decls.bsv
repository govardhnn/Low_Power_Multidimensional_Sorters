/*
MIT License Copyright (c) 2023 - 2024 Sai Govardhan

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
``Software''), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ``AS IS'', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
*/
package C_import_decls;

// ================================================================
// Copyright (c) 2013-2016 Bluespec, Inc. All Rights Reserved

// import BDPI declarations for C functions used in BSV modeling of memory

// ================================================================
		 
import Vector       :: *;

// ================================================================

import "BDPI" function ActionValue #(Bit #(64)) c_malloc_and_init (Bit #(64) n_bytes,
								   Bit #(64) init_from_file);

import "BDPI" function ActionValue #(Bit #(64)) c_read  (Bit #(64) addr, Bit #(64) n_bytes);

import "BDPI" function ActionValue #(Bit #(64)) c_get_start_pc ();

import "BDPI" function Action c_write (Bit #(64) addr, Bit #(64) x, Bit #(64) n_bytes);

import "BDPI" function ActionValue #(Vector #(10, Bit #(64))) c_get_console_command ();

// ================================================================

endpackage: C_import_decls
