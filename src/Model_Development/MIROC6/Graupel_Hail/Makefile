### Makefile MIROC proj/full
###

include	../../../Mkinclude

DIR		= proj/full

FFLAGS		= $(STDFFLAGS) -I$(INCDIR) -I$(OINCDIR) -I$(MPIINCDIR)

CFLAGS		= $(STDCFLAGS) -I$(INCDIR) -I$(OINCDIR) -I$(MPIINCDIR)

CPPFLAGS	= $(STDCPPFLAGS) $(CPPOPT)-I$(INCDIR) $(CPPOPT)-I$(OINCDIR) $(CPPOPT)-I$(MPIINCDIR) $(OPTIONS_PROJ)

LDFLAGS		= $(STDLDFLAGS)

EXTHDRS		= $(INCDIR)/zccom.F \
		  $(INCDIR)/zcdim.F \
		  $(INCDIR)/zgdim.F \
		  $(INCDIR)/zhdim.F \
		  $(INCDIR)/zkdim.F \
		  $(INCDIR)/zpdim.F \
		  $(INCDIR)/zqsat.F \
		  $(INCDIR)/zxmpif.F

HDRS		=

MAKEFILE	= Makefile

OBJS		= $(SPECIAL)

OBJSA		= $(SPECIALA) $(SPECIALC)

SRCS		= $(OBJS:.o=.F)

SRCS_ALL	=


all:
	@if [ $(GCM) = "CGCM" ] ; then \
	  $(MAKE) cgcm ; \
	else \
	  $(MAKE) agcm ; \
	fi

cgcm:	$(OBJS)
	echo $(OBJS) > SPECIALLIST
	cp $(OBJS) SPECIALLIST $(SRCDIR)

agcm:	$(OBJSA)
	echo $(OBJSA) > SPECIALLIST
	cp $(OBJSA) SPECIALLIST $(SRCDIR)

clean:
	$(RM) $(TRASH) SPECIALLIST

distclean: clean

index:
	@$(INDEX) $(HDRS) $(SRCS)

tags:
	@$(TAGS) $(HDRS) $(SRCS)

pack:	$(SRCS_ALL:.F=.ftr)

ftr:	$(SRCS_ALL:.F=.ftr)

rmftr:
	$(RM) $(FTRFILE)

sublist:
	egrep '( SUBROU| ENTRY  )' $(SRCS) /dev/null | $(AWK) -f $(SCRIPTDIR)/util/sublist dir=$(DIR) | sort > SUBLIST

html:	$(SRCS_ALL:.F=.html)

###

### Local Variables:
### mode: makefile
### tab-width: 8
### end:
