//
//  UserDTO+CoreDataProperties.m
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 16.01.2020.
//
//

#import "UserDTO+CoreDataProperties.h"

@implementation UserDTO (CoreDataProperties)

+ (NSFetchRequest<UserDTO *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"UserDTO"];
}

@dynamic firstName;
@dynamic lastName;

@end
