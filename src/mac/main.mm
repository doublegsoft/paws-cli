#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>
#import <clix-mac.h>

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
  
void handleOnClick(int x, int y, const char* imagePath, bool required, bool relative) override
{
  if (imagePath != NULL)
  {
    if (relative)
    {
      if (required)
        [simulator clickAtOffsetX:x andY:y untilFound:[NSString stringWithFormat:@"%s/%s", pal_root_dir, imagePath]];
      else
        [simulator clickAtOffsetX:x andY:y ifFound:[NSString stringWithFormat:@"%s/%s", pal_root_dir, imagePath]];
    }
    else
      if (required)
        ;// [simulator clickAtX:x andY:y untilSeen:[NSString stringWithFormat:@"%s/%s", PAL_ROOT_DIR, imagePath]];
      else
        [simulator clickAtX:x andY:y ifFound:[NSString stringWithFormat:@"%s/%s", pal_root_dir, imagePath]];
  }
  else
    [simulator clickAtX:x andY:y];
}
  
void handleOnMove(int x, int y, const char* path) override
{
  if (path != NULL)
  {
    
  }
  [simulator moveToX:x andY:y];
}
  
void handleOnScroll(int offset, const char* direction, const char* path) override
{
  if (path == NULL)
    NSLog(@"scroll %s %d", direction, offset);
  else
    NSLog(@"scroll %s %d %s", direction, offset, path);
}
  
void handleOnSave(const char* path) override
{
  NSString* templateString = [NSString stringWithUTF8String:path];

  NSString* filePath = templateString;
  NSString *fileName = [[filePath lastPathComponent] stringByDeletingPathExtension];
  NSString* extension = [filePath pathExtension];

  NSCalendar* calendar = [NSCalendar currentCalendar];
  NSDateComponents* components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[NSDate date]];
  NSString* datetime = [NSString stringWithFormat:@"%04ld%02ld%02ld%02ld%02ld%02ld",
                       (long)components.year,
                       (long)components.month,
                       (long)components.day,
                       (long)components.hour,
                       (long)components.minute,
                       (long)components.second];

  NSString* renderedPath = [NSString stringWithFormat:@"%@-%@.%@", fileName, datetime, extension];
  
  NSPasteboard* pasteboard = [NSPasteboard generalPasteboard];
  NSArray* classes = @[[NSString class], [NSAttributedString class], [NSURL class]];
  NSDictionary* options = @{};

  if ([pasteboard canReadObjectForClasses:classes options:options]) {
    NSArray* objects = [pasteboard readObjectsForClasses:classes options:options];
    for (id object in objects) {
      if ([object isKindOfClass:[NSString class]]) {
        NSString* content = (NSString*) object;
        content = [content stringByAppendingString:@"\n"];
        NSString* filePath = [NSString stringWithFormat:@"%s/%@", pal_root_dir, renderedPath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:filePath]) {
          [fileManager createFileAtPath:filePath contents:nil attributes:nil];
        }
        NSFileHandle* fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
        [fileHandle seekToEndOfFile];
        NSData* data = [content dataUsingEncoding:NSUTF8StringEncoding];
        [fileHandle writeData:data];
        [fileHandle closeFile];
      }
    }
  }
}
  
void handleOnPaste(const char* text) override
{
  [simulator pasteFromText:[NSString stringWithUTF8String:text]];
}
  
void handleOnEnter() override
{
  CGEventRef event = CGEventCreateKeyboardEvent(NULL, kVK_ANSI_KeypadEnter, YES);
  CGEventPost(kCGHIDEventTap, event);
  CFRelease(event);
}

void handleOnRemove(const char* path) override
{

}
  
ClixMacSimulator* simulator;
  
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
  @autoreleasepool {
    gfc_gc_init();
    
    PawsHandler handler;
    handler.simulator = [[ClixMacSimulator alloc] initWithDirectory:[NSString stringWithUTF8String:wd]];
    
    pal::Program prog(&handler);
    
    NSError* error = nil;
    NSString* filePath = [NSString stringWithUTF8String:pal];
    NSString* fileContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];

    prog.Evaluate([fileContent UTF8String], (int)fileContent.length);
  }
  
  return 0;
}

