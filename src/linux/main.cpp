/*
** ██████╗░░█████╗░░██╗░░░░░░░██╗░██████╗░░░░░░░█████╗░██╗░░░░░██╗
** ██╔══██╗██╔══██╗░██║░░██╗░░██║██╔════╝░░░░░░██╔══██╗██║░░░░░██║
** ██████╔╝███████║░╚██╗████╗██╔╝╚█████╗░█████╗██║░░╚═╝██║░░░░░██║
** ██╔═══╝░██╔══██║░░████╔═████║░░╚═══██╗╚════╝██║░░██╗██║░░░░░██║
** ██║░░░░░██║░░██║░░╚██╔╝░╚██╔╝░██████╔╝░░░░░░╚█████╔╝███████╗██║
** ╚═╝░░░░░╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░╚═════╝░░░░░░░░╚════╝░╚══════╝╚═╝
*/
#include <clix-desktop.h>
#include <gfc.h>
#include <libpal.hpp>
#include <argparse.h>

static const char *const usages[] = 
{
  "paws [options]",
  NULL,
};

#define PAL_ROOT_DIR            "/Users/christian/Paws"

static const char* pal_root_dir = NULL;

class PawsHandler : public pal::InstructionHandler
{
  
public:

PawsHandler()
{
  context = clix_context_init();
}
  
~PawsHandler()
{
  clix_context_free(context);
}

void handleOnClick(int x, int y, const char* imagePath, bool required, bool relative) override
{
  if (imagePath != NULL) 
  {
    if (required) 
    {
      // clix_click_on_image(context, imagePath);
    }
    else
    {
      // clix_click_on_image_if_exists(context, imagePath);
    }
  }
  else
  {
    clix_click_at_point(context, x, y);
  }
}
  
void handleOnMove(int x, int y, const char* path) override
{
  clix_move_to_point(context, x, y);
}
  
void handleOnScroll(int offset, const char* direction, const char* path) override
{
  clix_scroll(context, offset);
}
  
void handleOnSave(const char* path) override
{
  clix_screen_capture(context, path);
}
  
void handleOnPaste(const char* text) override
{
  clix_paste_from_text(context, text);
}
  
void handleOnEnter() override
{
  clix_enter(context);
}

void handleOnRemove(const char* path) override
{

}

private:
  clix_context_t* context;
  
};

int
main(int argc, char* argv[])
{
  char* pal = NULL;
  char* wd = NULL;

  struct argparse_option options[] = {
    OPT_HELP(),
    OPT_STRING('p', "pal", &pal, "the PAL script path", NULL, 0, 0),
    OPT_STRING('w', "work_directory", &wd, "the work directory", NULL, 0, 0),
    OPT_END(),
  };
  struct argparse argparse;
  argparse_init(&argparse, options, usages, 0);
  argparse_describe(&argparse, "\nExecute PAL automation script.", NULL);
  
  argc = argparse_parse(&argparse, argc, (const char**) argv);
  if (pal == NULL || wd == NULL) 
  {
    argparse_usage(&argparse);
    return -1;
  }
  pal_root_dir = wd;
  gfc_gc_init();
    
  PawsHandler handler;
  
  return 0;
}

