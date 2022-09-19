PN = retroarch-standalone-service

PREFIX ?= /usr
INITDIR = $(PREFIX)/lib/systemd/system
USERDIR = $(PREFIX)/lib/sysusers.d
TMPFDIR = $(PREFIX)/lib/tmpfiles.d
UDEVDIR = $(PREFIX)/lib/udev/rules.d
POLKDIR = $(PREFIX)/share/polkit/rules.d
MANDIR = $(PREFIX)/share/man/man1
ENVDIR = /etc/conf.d

RM = rm
INSTALL = install -p
INSTALL_DIR = $(INSTALL) -d
INSTALL_PROGRAM = $(INSTALL) -m755
INSTALL_DATA = $(INSTALL) -m644

IS_ARCH_ARM := $(shell uname -m | grep -q -E "^(arm|aarch64)"; echo $$?)
ifeq ($(IS_ARCH_ARM), 0)
	ARCH = arm
else
	ARCH = x86
endif

common/$(PN):
	@echo -e '\033[1;32mNothing to be done.\033[0m'
	@echo -e '\033[1;32mJust run make install as root.\033[0m'

install-common:
	$(INSTALL_DIR) "$(DESTDIR)$(UDEVDIR)"
	$(INSTALL_DIR) "$(DESTDIR)$(ENVDIR)"
	$(INSTALL_DATA) $(ARCH)/udev/99-retroarch.rules "$(DESTDIR)$(UDEVDIR)/99-retroarch.rules"
	$(INSTALL_DATA) common/retroarch-standalone "$(DESTDIR)$(ENVDIR)/retroarch-standalone"
ifeq ($(ARCH),arm)
	$(INSTALL_DIR) "$(DESTDIR)$(POLKDIR)"
	$(INSTALL_DATA) $(ARCH)/polkit/polkit.rules "$(DESTDIR)$(POLKDIR)/99-retroarch.rules"
endif

install-init:
	$(INSTALL_DIR) "$(DESTDIR)$(INITDIR)"
	$(INSTALL_DIR) "$(DESTDIR)$(USERDIR)"
	$(INSTALL_DIR) "$(DESTDIR)$(TMPFDIR)"
ifeq ($(ARCH),x86)
	$(INSTALL_DATA) $(ARCH)/init/retroarch-gbm.service "$(DESTDIR)$(INITDIR)/retroarch-gbm.service"
	$(INSTALL_DATA) $(ARCH)/init/retroarch-wayland.service "$(DESTDIR)$(INITDIR)/retroarch-wayland.service"
	$(INSTALL_DATA) $(ARCH)/init/retroarch-x11.service "$(DESTDIR)$(INITDIR)/retroarch-x11.service"
else
	$(INSTALL_DATA) $(ARCH)/init/retroarch.service "$(DESTDIR)$(INITDIR)/retroarch.service"
endif
	$(INSTALL_DATA) $(ARCH)/init/tmpfiles.conf "$(DESTDIR)$(TMPFDIR)/retroarch-standalone.conf"
	$(INSTALL_DATA) $(ARCH)/init/sysusers.conf "$(DESTDIR)$(USERDIR)/retroarch-standalone.conf"

install-man:
	$(INSTALL_DIR) "$(DESTDIR)$(MANDIR)"
	$(INSTALL_DATA) $(ARCH)/doc/retroarch.service.1 "$(DESTDIR)$(MANDIR)/retroarch.service.1"

uninstall:
ifeq ($(ARCH),x86)
	$(RM) "$(DESTDIR)$(INITDIR)/retroarch-gbm.service"
	$(RM) "$(DESTDIR)$(INITDIR)/retroarch-wayland.service"
	$(RM) "$(DESTDIR)$(INITDIR)/retroarch-x11.service"
else
	$(RM) "$(DESTDIR)$(INITDIR)/retroarch.service"
	$(RM) "$(DESTDIR)$(POLKDIR)/99-retroarch.rules"
endif
	$(RM) "$(DESTDIR)$(TMPFDIR)/retroarch-standalone.conf"
	$(RM) "$(DESTDIR)$(USERDIR)/retroarch-standalone.conf"
	$(RM) "$(DESTDIR)$(UDEVDIR)/99-retroarch.rules"
	$(RM) "$(DESTDIR)$(MANDIR)/retroarch.service.1"
	$(RM) "$(DESTDIR)$(ENVDIR)/retroarch-standalone"

install: install-common install-init install-man

.PHONY: install-common install-init uninstall
