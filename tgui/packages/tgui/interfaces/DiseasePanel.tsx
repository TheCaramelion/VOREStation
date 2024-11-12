import { useState } from 'react';

import { useBackend } from '../backend';
import { Section, Stack, Table, Tabs } from '../components';
import { Window } from '../layouts';

type Disease = {
  commonName: string;
  description: string;
  treatment: string;
  transmission: string;
};

type Symptom = {
  name: string;
  stealth: string;
  resistance: number;
  stageSpeed: number;
  tramsittable: string;
};

type Infectee = {
  name: string;
  ref: string;
};

type Data = {
  diseases: Disease[];
  symptoms: Symptom[];
  infectees: Infectee[] | null; // Allow null in case of missing data
};

export const DiseasePanel = () => {
  const { data } = useBackend<Data>();
  const { diseases, symptoms, infectees } = data;

  // Basic error handling if diseases data is missing or empty
  if (!diseases || diseases.length === 0) {
    return (
      <Window width={575} height={510}>
        <Window.Content>
          <Stack fill vertical>
            <Section title="No Diseases Found">
              <p>No diseases data available.</p>
            </Section>
          </Stack>
        </Window.Content>
      </Window>
    );
  }

  // Track the selected tab (Diseases or Symptoms)
  const [selectedTab, setSelectedTab] = useState<'diseases' | 'symptoms'>(
    'diseases',
  );

  return (
    <Window width={575} height={510}>
      <Window.Content>
        <Stack fill vertical>
          <Tabs>
            {/* Tab for Diseases List */}
            <Tabs.Tab
              icon="virus"
              selected={selectedTab === 'diseases'}
              onClick={() => setSelectedTab('diseases')}
            >
              Diseases
            </Tabs.Tab>

            {/* Tab for Symptoms List */}
            <Tabs.Tab
              icon="heartbeat"
              selected={selectedTab === 'symptoms'}
              onClick={() => setSelectedTab('symptoms')}
            >
              Symptoms
            </Tabs.Tab>
          </Tabs>

          {/* Conditionally render the selected tab content */}
          {selectedTab === 'diseases' && (
            <Section title="Diseases List">
              <Table>
                <Table.Row header>
                  <Table.Cell>Common Name</Table.Cell>
                  <Table.Cell>Description</Table.Cell>
                  <Table.Cell>Treatment</Table.Cell>
                  <Table.Cell>Transmission</Table.Cell>
                </Table.Row>
                {diseases.map((disease, index) => (
                  <Table.Row key={index}>
                    <Table.Cell>{disease.commonName}</Table.Cell>
                    <Table.Cell>{disease.description}</Table.Cell>
                    <Table.Cell>{disease.treatment}</Table.Cell>
                    <Table.Cell>{disease.transmission}</Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            </Section>
          )}

          {selectedTab === 'symptoms' && (
            <Section title="Symptoms List">
              <p>Symptoms data will be shown here in the future.</p>
            </Section>
          )}

          {/* Displaying all the people from the infectees (Infectee) */}
          <Section title="Infectee List">
            <Table>
              <Table.Row header>
                <Table.Cell>Name</Table.Cell>
              </Table.Row>
              {infectees && infectees.length > 0 ? (
                infectees.map((infectee, index) => (
                  <Table.Row key={index}>
                    <Table.Cell>{infectee.name}</Table.Cell>{' '}
                    {/* Corrected reference */}
                  </Table.Row>
                ))
              ) : (
                <Table.Row>
                  <Table.Cell>No infectees available</Table.Cell>
                </Table.Row>
              )}
            </Table>
          </Section>
        </Stack>
      </Window.Content>
    </Window>
  );
};
