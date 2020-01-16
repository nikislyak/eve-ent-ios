//
//  UserDTO+CoreDataProperties.h
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 16.01.2020.
//
//

#import "UserDTO+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface UserDTO (CoreDataProperties)

+ (NSFetchRequest<UserDTO *> *)fetchRequest;

@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;

@end

NS_ASSUME_NONNULL_END
