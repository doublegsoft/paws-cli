/*
** ██████╗░░█████╗░░██╗░░░░░░░██╗░██████╗░░░░░░░█████╗░██╗░░░░░██╗
** ██╔══██╗██╔══██╗░██║░░██╗░░██║██╔════╝░░░░░░██╔══██╗██║░░░░░██║
** ██████╔╝███████║░╚██╗████╗██╔╝╚█████╗░█████╗██║░░╚═╝██║░░░░░██║
** ██╔═══╝░██╔══██║░░████╔═████║░░╚═══██╗╚════╝██║░░██╗██║░░░░░██║
** ██║░░░░░██║░░██║░░╚██╔╝░╚██╔╝░██████╔╝░░░░░░╚█████╔╝███████╗██║
** ╚═╝░░░░░╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░╚═════╝░░░░░░░░╚════╝░╚══════╝╚═╝
*/
#include <clix-desktop.hpp>
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
  simulator = new ClixDesktopSimulator(pal_root_dir);
}
  
~PawsHandler()
{
  delete simulator;
}

void handleOnClick(int x, int y, const char* imagePath, bool required, bool relative) override
{
  if (imagePath != NULL) 
  {
    if (required) 
    {
      if (relative)
        simulator->clickAtPointUntilFound(x, y, imagePath, 200);
      else
        simulator->clickAtOffsetUntilFound(x, y, imagePath, 200);
    }
    else
    {
      simulator->clickAtOffsetIfFound(x, y, imagePath);
    }
  }
  else
  {
    simulator->clickAt(x, y);
  }
}
  
void handleOnMove(int x, int y, const char* path) override
{
  simulator->moveTo(x, y);
}
  
void handleOnScroll(int offset, const char* direction, const char* path) override
{
  simulator->scroll(offset);
}
  
void handleOnSave(const char* path) override
{
  simulator->save(path);
}
  
void handleOnPaste(const char* text) override
{
  simulator->pasteFromText(text);
}
  
void handleOnEnter() override
{
  simulator->enter();
}

void handleOnRemove(const char* path) override
{

}

private:
  
  ClixDesktopSimulator* simulator;
  
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
  pal::Program prog(&handler);
  prog.Evaluate(pal);
  
  return 0;
}

