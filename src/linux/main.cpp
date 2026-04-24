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
    std::string full_path = pal_root_dir;
    full_path += "/";
    full_path += imagePath;
    if (required) 
    {
      if (relative)
        simulator->clickAtOffsetUntilFound(x, y, full_path.c_str(), 200);
      else
        simulator->clickAtPointUntilFound(x, y, full_path.c_str(), 200);
    }
    else
    {
      simulator->clickAtOffsetIfFound(x, y, full_path.c_str());
    }
  }
  else
  {
    simulator->clickAt(x, y);
  }
}

void handleOnClick(int x, int y, int delta, const char* path, bool required, bool relative) 
{
  // TODO
  if (path != NULL) 
  {
    std::string full_path = pal_root_dir;
    full_path += "/";
    full_path += path;
    if (required) 
    {
      if (relative)
        simulator->clickAtOffsetUntilFound(x, y, full_path.c_str(), 200);
      else
        simulator->clickAtPointUntilFound(x, y, full_path.c_str(), 200);
    }
    else
    {
      simulator->clickAtOffsetIfFound(x, y, full_path.c_str());
    }
  }
  else
  {
    // simulator->scrollAt(x, y, delta);
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
  std::string full_path = pal_root_dir;
  full_path += "/";
  full_path += path;
  FILE* fp = fopen(full_path.c_str(), "a"); 
  if (fp == NULL) {
    perror("fopen failed");
    return;
  }

  const char *cmd = "wl-paste 2>/dev/null || "
                      "xclip -selection clipboard -o 2>/dev/null || "
                      "xsel --clipboard --output 2>/dev/null";

  FILE* pipe = popen(cmd, "r");
  if (!pipe) {
    perror("popen");
    return;
  }

  char* buf = NULL;
  size_t cap = 0;
  size_t len = 0;
  char chunk[4096];

  while (fgets(chunk, sizeof(chunk), pipe)) {
    size_t clen = strlen(chunk);
    if (len + clen + 1 > cap) {
      cap = len + clen + 4096;
      char* newbuf = (char*)realloc(buf, cap);
      if (!newbuf) {
        free(buf);
        pclose(pipe);
        return;
      }
      buf = newbuf;
    }
    memcpy(buf + len, chunk, clen);
    len += clen;
  }

  if (buf) buf[len] = '\0';

  fprintf(fp, "%s\n", buf);

  pclose(pipe);
  fclose(fp);
  free(buf);
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

