import { useBackend, useSharedState } from '../backend';
import { AnimatedNumber, Box, Button, ColorBox, LabeledList, NumberInput, Section, Table } from '../components';
import { Window } from '../layouts';

export const AbnoChem = (props, context) => {
  const { data } = useBackend(context);
  const { screen } = data;
  return (
    <Window
      width={465}
      height={550}>
      <Window.Content scrollable>
        <MoveButtons />
        {screen === 'ac_mix' && (
          <Mix />
        ) || screen === 'ac_create' && (
          <Create />
        ) || screen === 'ac_refine' && (
          <Refine />
        ) || (
          <Home />
        )}
      </Window.Content>
    </Window>
  );
};

const MoveButtons = (props, context) => {
  const { act, data } = useBackend(context);
  const { screen } = data;
  return (
    <Section>
      {screen !== 'ac_home' && (
        <Button
        content={"Home"}
        onClick={() => act("changeScreen", { to_screen: "ac_home" })} />
      )}
      {screen !== 'ac_mix' && (
        <Button
        content={"Mix"}
        onClick={() => act("changeScreen", { to_screen: "ac_mix" })} />
      )}
      {screen !== 'ac_create' && (
        <Button
        content={"Create"}
        onClick={() => act("changeScreen", { to_screen: "ac_create" })} />
      )}
      {screen !== 'ac_refine' && (
        <Button
        content={"Refine"}
        onClick={() => act("changeScreen", { to_screen: "ac_refine" })} />
      )}
    </Section>
  );
};

const Home = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    screen,
    containerContents = [],
    bufferContents = [],
    mixerContents = [],
    containerCurrentVolume,
    containerMaxVolume,
    container,
    move_destination,
  } = data;
  if (screen === 'ac_mix') {
    return <Mix />;
  }
  else if (screen === 'ac_create') {
    return <Create />;
  }
  else if (screen === 'ac_options') {
    return <Refine />;
  }
  return (
    <>
      <Section
        title="Container"
        buttons={!!data.container && (
          <>
            <Box inline color="label" mr={2}>
              <AnimatedNumber
                value={containerCurrentVolume}
                initial={0} />
              {` / ${containerMaxVolume} units`}
            </Box>
            <Button
              icon="eject"
              content="Eject"
              onClick={() => act('eject')} />
          </>
        )}>
        {!container && (
          <Box color="label" mt="3px" mb="5px">
            No container loaded.
          </Box>
        )}
        {!!container && containerContents.length === 0 && (
          <Box color="label" mt="3px" mb="5px">
            Container is empty.
          </Box>
        )}
        <ChemicalBuffer>
          {containerContents.map(chemical => (
            <ChemicalBufferEntry
              key={chemical.id}
              chemical={chemical}
              transferTo={move_destination}
              source="Container" />
          ))}
        </ChemicalBuffer>
      </Section>
      <Section
        title="Buffer"
        buttons={(
          <>
            <Box inline color="label" mr={1}>
              Mode:
            </Box>
            <Button
              color={move_destination !== "Destroy" ? 'good' : 'bad'}
              icon={move_destination !== "Destroy" ? 'exchange-alt' : 'times'}
              content={move_destination}
              onClick={() => act('toggleMove')} />
          </>
        )}>
        {bufferContents.length === 0 && (
          <Box color="label" mt="3px" mb="5px">
            Buffer is empty.
          </Box>
        )}
        <ChemicalBuffer>
          {bufferContents.map(chemical => (
            <ChemicalBufferEntry
              key={chemical.id}
              chemical={chemical}
              transferTo={move_destination}
              source="Buffer" />
          ))}
        </ChemicalBuffer>
      </Section>
      <Section
        title="Mixing Chamber"
        buttons={(
          <>
            <Box inline color="label" mr={1}>
              Mode:
            </Box>
            <Button
              color={move_destination !== "Destroy" ? 'good' : 'bad'}
              icon={move_destination !== "Destroy" ? 'exchange-alt' : 'times'}
              content={move_destination}
              onClick={() => act('toggleMove')} />
          </>
        )}>
        {mixerContents.length === 0 && (
          <Box color="label" mt="3px" mb="5px">
            Mixing Chamber is empty.
          </Box>
        )}
        <ChemicalBuffer>
          {mixerContents.map(chemical => (
            <ChemicalBufferEntry
              key={chemical.id}
              chemical={chemical}
              transferTo={move_destination}
              source="Mixer" />
          ))}
        </ChemicalBuffer>
      </Section>
    </>
  );
};

const Mix = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    screen,
    containerContents = [],
    bufferContents = [],
    containerCurrentVolume,
    containerMaxVolume,
    container,

  } = data;
  return (
    <Section>

    </Section>
  );
};

const Create = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    screen,
    containerContents = [],
    bufferContents = [],
    containerCurrentVolume,
    containerMaxVolume,
    container,
    recipes = [],
  } = data;
  return (
    <Section title="Recipes">
      <RecipeList>
        {recipes.map(recipe => (
          <RecipeListEntry
            key={recipe.id}
            recipe={recipe}
            reqList={data["reqs"+recipe.name]}
            showReq={data[recipe.name]} />
        ))}
      </RecipeList>
    </Section>
  );
};

const Refine = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    screen,
    containerContents = [],
    bufferContents = [],
    containerCurrentVolume,
    containerMaxVolume,
    container,
    RefineRecipes = [],
    ReagentRecipes = [],
  } = data;
  return (
    <Box>
      <Section title="Refine">
        <RecipeList>
          {RefineRecipes.map(recipe => (
            <RecipeListEntry
              key={recipe.id}
              recipe={recipe}
              reqList={data["reqs"+recipe.name]}
              showReq={data[recipe.name]} />
          ))}
        </RecipeList>
      </Section>
      <Section title="Reagents">
        <RecipeList>
          {ReagentRecipes.map(recipe => (
            <RecipeListEntry
              key={recipe.id}
              recipe={recipe}
              reqList={data["reqs"+recipe.name]}
              showReq={data[recipe.name]} />
          ))}
        </RecipeList>
      </Section>
    </Box>
  );
};

const RecipeList = Table;

const RecipeListEntry = (props, context) => {
  const { act, data } = useBackend(context);
  const { recipe = [],
          reqList = [],
          showReq,
        } = props;
  return (
    <Table.Row key={recipe.id}>
      <RecipeContent width="100%">
        <Table.Row collapsing>
           <Table.Cell color="label">
            <Box color="label" mt="4px" mb="6px">
              {recipe.name}
            </Box>
          </Table.Cell>
          <Table.Cell collapsing>
            <Button
              bold content={"V"}
              onClick={() => act("changeShow", { value: recipe.name })} />
          </Table.Cell>
          <Table.Cell collapsing>
            <Button
              icon="plus" bold content={"Create"}
              onClick={() => act("create", { recipe_type: recipe.name })} />
          </Table.Cell>
        </Table.Row>
        { showReq === 1 && (
          reqList.map(req => (
            <RecipeContentEntry
              key={req.id}
              requirement={req}
            />
           )) || showReq === 0 && (<Table.Row key={recipe.desc}>
              <Box color="label" mt="3px" mb="5px">
                {" □ "+recipe.desc}
              </Box>
            </Table.Row>)
        )}
      </RecipeContent>
    </Table.Row>
  );
};

const RecipeContent = Table;

const RecipeContentEntry = (props, context) => {
  const { requirement } = props;
  return (
    <Table.Row key={requirement.id}>
      <Box color={requirement.meets_req} mt="3px" mb="5px">
        {" ● "+requirement.name + ": " + requirement.volume}
      </Box>
    </Table.Row>
  );
};

const ChemicalBuffer = Table;

const ChemicalBufferEntry = (props, context) => {
  const { act } = useBackend(context);
  const { chemical, transferTo, source } = props;
  return (
    <Table.Row key={chemical.id}>
      <Table.Cell color="label">
        <AnimatedNumber
          value={chemical.volume}
          initial={0} />
        {` units of ${chemical.name}`}
      </Table.Cell>
      <Table.Cell collapsing>
        <Button
          content="1"
          onClick={() => act('transfer', {
            id: chemical.id,
            amount: 1,
            to: transferTo,
            from: source,
          })} />
        <Button
          content="5"
          onClick={() => act('transfer', {
            id: chemical.id,
            amount: 5,
            to: transferTo,
            from: source,
          })} />
        <Button
          content="10"
          onClick={() => act('transfer', {
            id: chemical.id,
            amount: 10,
            to: transferTo,
            from: source,
          })} />
        <Button
          content="All"
          onClick={() => act('transfer', {
            id: chemical.id,
            amount: 1000,
            to: transferTo,
            from: source,
          })} />
        <Button
          icon="ellipsis-h"
          title="Custom amount"
          onClick={() => act('transfer', {
            id: chemical.id,
            amount: -1,
            to: transferTo,
            from: source,
          })} />
      </Table.Cell>
    </Table.Row>
  );
};
