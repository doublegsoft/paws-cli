#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>
#import <clix-mac.h>

#include <gfc.h>
#include <libpal.hpp>

#define PAL_ROOT_DIR            "/Users/christian/Paws"

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
        [simulator clickAtOffsetX:x andY:y untilFound:[NSString stringWithFormat:@"%s/%s", PAL_ROOT_DIR, imagePath]];
      else
        [simulator clickAtOffsetX:x andY:y ifFound:[NSString stringWithFormat:@"%s/%s", PAL_ROOT_DIR, imagePath]];
    }
    else
      if (required)
        ;// [simulator clickAtX:x andY:y untilSeen:[NSString stringWithFormat:@"%s/%s", PAL_ROOT_DIR, imagePath]];
      else
        [simulator clickAtX:x andY:y ifFound:[NSString stringWithFormat:@"%s/%s", PAL_ROOT_DIR, imagePath]];
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
  NSString* renderedPath = templateString;
  
  NSPasteboard* pasteboard = [NSPasteboard generalPasteboard];
  NSArray* classes = @[[NSString class], [NSAttributedString class], [NSURL class]];
  NSDictionary* options = @{};

  if ([pasteboard canReadObjectForClasses:classes options:options]) {
    NSArray* objects = [pasteboard readObjectsForClasses:classes options:options];
    for (id object in objects) {
      if ([object isKindOfClass:[NSString class]]) {
        NSString* content = (NSString*) object;
        content = [content stringByAppendingString:@"\n"];
        NSString* filePath = [NSString stringWithFormat:@"%s/%@", PAL_ROOT_DIR, renderedPath];
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
  
ClixMacSimulator* simulator;
  
};

int
main(int argc, char* argv[])
{
  @autoreleasepool {
    gfc_gc_init();
    
    PawsHandler handler;
    handler.simulator = [[ClixMacSimulator alloc] initWithDirectory:@PAL_ROOT_DIR];
    
    pal::Program prog(&handler);
    
    NSError* error = nil;
    NSString* filePath = @PAL_ROOT_DIR "/paws.pal";
    NSString* fileContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    
    prog.Evaluate([fileContent UTF8String], (int)fileContent.length);
  }
  
  return 0;
}

