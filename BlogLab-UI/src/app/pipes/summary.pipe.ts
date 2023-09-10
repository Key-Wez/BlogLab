import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'summary'
})
export class SummaryPipe implements PipeTransform {

  transform(content: string, characterLimits: number): string {
    if (content.length <= characterLimits) {
      return content;
    } else {
      return `${content.substring(0, characterLimits)}...`;
    }
  }
}
