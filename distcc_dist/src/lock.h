/* -*- c-file-style: "java"; indent-tabs-mode: nil -*-
 * 
 * distcc -- A simple distributed compiler system
 *
 * Copyright (C) 2002, 2003 by Martin Pool <mbp@samba.org>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
 * USA
 */

int dcc_lock_host(const char *lockname,
                  const struct dcc_hostdef *host, int slot, int block,
                  int *lock_fd);

int dcc_unlock(int lock_fd);

int dcc_make_lock_filename(const char *lockname,
                           const struct dcc_hostdef *host,
                           int iter,
                           char **);

int dcc_open_lockfile(const char *fname, int *plockfd);

int dcc_get_cpp_lock();
void dcc_unlock_cpp_lock();

